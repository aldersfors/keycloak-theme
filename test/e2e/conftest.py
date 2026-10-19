"""Shared fixtures for the end-to-end tests against the preview stack (preview/compose.yaml).

The tests run inside the Playwright container on the compose network, so Keycloak is
reachable as http://keycloak:8080 and Mailpit as http://mailpit:8025.
"""

import base64
import hashlib
import os
import pathlib
import secrets
import time
from urllib.parse import urlencode, urlparse

import pyotp
import pytest
import requests
from playwright.sync_api import sync_playwright

BASE = os.environ.get("KC_URL", "http://keycloak:8080")
MAILPIT = os.environ.get("MAILPIT_URL", "http://mailpit:8025")
REALM = "homelab"
PASSWORD = "Passw0rd!"
# The raw OTP secret stored for alice in preview/realm-homelab.json; authenticator apps
# (and pyotp) take its base32 encoding.
ALICE_OTP_SECRET = "alicealicealicealice"
OUT = pathlib.Path(os.environ.get("TEST_OUT", "test/out"))

PHONE = {"width": 390, "height": 844}
DESKTOP = {"width": 1280, "height": 800}


def origin(url: str) -> str:
    parts = urlparse(url)
    return f"{parts.scheme}://{parts.netloc}"


def totp_now() -> str:
    """A TOTP code for alice that has not been used yet. Keycloak rejects a code that was
    already accepted in the same 30s window, so wait for the next one when needed. The last
    code is kept in a file so back-to-back test runs (separate processes) also respect it."""
    totp = pyotp.TOTP(base64.b32encode(ALICE_OTP_SECRET.encode()).decode())
    last_file = OUT / ".last-otp"
    last = last_file.read_text().strip() if last_file.exists() else None
    code = totp.now()
    while code == last:
        time.sleep(1)
        code = totp.now()
    OUT.mkdir(parents=True, exist_ok=True)
    last_file.write_text(code)
    return code


@pytest.fixture(scope="session")
def browser():
    with sync_playwright() as pw:
        b = pw.chromium.launch()
        yield b
        b.close()


@pytest.fixture
def make_page(browser):
    """Return a factory for pages with a viewport and colour scheme. Every page records the
    URLs it requested in ``page.requested``."""
    contexts = []

    def factory(viewport=PHONE, scheme="light", locale="sv-SE"):
        ctx = browser.new_context(viewport=viewport, color_scheme=scheme, locale=locale)
        contexts.append(ctx)
        page = ctx.new_page()
        page.requested = []
        page.on("request", lambda req: page.requested.append(req.url))
        return page

    yield factory
    for ctx in contexts:
        ctx.close()


@pytest.fixture
def page_phone_light(make_page):
    return make_page(PHONE, "light")


@pytest.fixture
def page_phone_dark(make_page):
    return make_page(PHONE, "dark")


@pytest.fixture
def page_desktop(make_page):
    return make_page(DESKTOP, "light")


@pytest.fixture
def login_url():
    """Authorisation URL that lands on the realm's login page for the account console."""

    def build(locale: str = "sv") -> str:
        verifier = secrets.token_urlsafe(48)
        challenge = base64.urlsafe_b64encode(hashlib.sha256(verifier.encode()).digest()).rstrip(b"=").decode()
        query = urlencode({
            "client_id": "account-console",
            "redirect_uri": f"{BASE}/realms/{REALM}/account/",
            "response_type": "code",
            "scope": "openid",
            "code_challenge": challenge,
            "code_challenge_method": "S256",
            "ui_locales": locale,
        })
        return f"{BASE}/realms/{REALM}/protocol/openid-connect/auth?{query}"

    return build


def sign_in(page, username: str, password: str = PASSWORD) -> None:
    page.fill("#username", username)
    page.fill("#password", password)
    page.click("#kc-login")


def submit_otp(page) -> None:
    page.fill("#otp", totp_now())
    page.click("#kc-login")


def shot(page, name: str) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    page.screenshot(path=str(OUT / f"{name}.png"), full_page=True)


@pytest.fixture
def mailpit():
    """Small client for the Mailpit API; clears the inbox before the test."""
    session = requests.Session()
    session.delete(f"{MAILPIT}/api/v1/messages", timeout=10)

    class Client:
        def messages(self):
            return session.get(f"{MAILPIT}/api/v1/messages", timeout=10).json()["messages"]

        def message(self, message_id: str):
            return session.get(f"{MAILPIT}/api/v1/message/{message_id}", timeout=10).json()

    return Client()
