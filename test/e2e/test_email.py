import re
import time

import requests

from conftest import OUT


def request_reset(make_page, login_url, username):
    page = make_page()
    page.goto(login_url("sv"))
    page.click('a[href*="reset-credentials"]')
    page.fill("#username", username)
    page.click('input[type="submit"], button[type="submit"]')
    page.wait_for_load_state("networkidle")


def wait_for_message(mailpit, timeout=10):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        messages = mailpit.messages()
        if messages:
            return mailpit.message(messages[0]["ID"])
        time.sleep(0.5)
    raise AssertionError("no email arrived within 10s")


def test_reset_password_email(make_page, login_url, mailpit):
    request_reset(make_page, login_url, "bob")
    message = wait_for_message(mailpit)
    html, text = message["HTML"], message["Text"]
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "email-reset.html").write_text(html)

    assert message["Subject"] == "Återställ lösenord"
    assert "<svg" in html and "hl-logo" in html, "logo missing"
    assert re.search(r'style="[^"]*background(-color)?:\s*#0d1b2a', html, re.I), "navy header missing"
    assert "Någon har precis bett om att ändra användaruppgifter" in html
    assert text.strip(), "plain-text part missing"

    links = re.findall(r'href="([^"]*login-actions/action-token[^"]*)"', html)
    assert links, "no action link"
    link = links[0].replace("&amp;", "&")
    assert requests.get(link, timeout=10).status_code == 200
