import pytest

from conftest import BASE, DESKTOP, PHONE, REALM, shot, sign_in

LIGHT_PAGE = "rgb(238, 242, 246)"
DARK_PAGE = "rgb(13, 27, 42)"
LIGHT_ERROR = "rgb(163, 36, 43)"
DARK_ERROR = "rgb(240, 160, 160)"


def style(page, selector, prop):
    return page.eval_on_selector(selector, f"el => getComputedStyle(el).getPropertyValue('{prop}')")


def box(page, selector):
    return page.locator(selector).first.bounding_box()


def no_overflow(page):
    return page.evaluate("document.documentElement.scrollWidth <= document.documentElement.clientWidth")


def open_login(make_page, login_url, viewport=PHONE, scheme="light", locale="sv"):
    page = make_page(viewport, scheme)
    page.goto(login_url(locale))
    page.wait_for_selector("#kc-login")
    return page


@pytest.mark.parametrize("scheme,expected", [("light", LIGHT_PAGE), ("dark", DARK_PAGE)])
def test_colours_follow_scheme(make_page, login_url, scheme, expected):
    page = open_login(make_page, login_url, scheme=scheme)
    shot(page, f"login-colours-{scheme}-390")
    assert style(page, "body", "background-color") == expected
    assert style(page, ".hl-title", "font-family").startswith('"Bricolage Grotesque"')


def test_phone_is_full_bleed(make_page, login_url):
    page = open_login(make_page, login_url)
    shot(page, "login-fullbleed-light-390")
    assert box(page, "#kc-form-login")["width"] >= 0.9 * PHONE["width"] - 44  # 22px gutters
    assert style(page, ".hl-shell", "border-top-width") == "0px"
    assert style(page, ".hl-shell", "box-shadow") == "none"


def test_desktop_is_card(make_page, login_url):
    page = open_login(make_page, login_url, viewport=DESKTOP)
    shot(page, "login-card-light-1280")
    card = box(page, ".hl-shell")
    assert 360 <= card["width"] <= 440, card
    left, right = card["x"], DESKTOP["width"] - (card["x"] + card["width"])
    assert abs(left - right) <= 2, (left, right)


@pytest.mark.parametrize("width", [320, 390])
def test_no_horizontal_overflow(make_page, login_url, width):
    page = make_page({"width": width, "height": 800}, "light")
    page.goto(login_url("sv"))
    page.wait_for_selector("#kc-login")
    assert no_overflow(page), "login overflows"

    sign_in(page, "alice")
    page.wait_for_selector("#otp")
    shot(page, f"login-otp-light-{width}")
    assert no_overflow(page), "OTP page overflows"

    page.goto(login_url("sv"))
    page.click('a[href*="reset-credentials"]')
    page.wait_for_selector("#username")
    shot(page, f"login-reset-light-{width}")
    assert no_overflow(page), "reset-password page overflows"


def test_header_shows_logo_and_realm(make_page, login_url):
    page = open_login(make_page, login_url)
    assert page.locator(".hl-header svg.hl-logo").count() == 1
    assert page.locator(".hl-header .hl-realm").inner_text().strip() == "Homelab"


def test_locale_switch(make_page, login_url):
    page = open_login(make_page, login_url)
    assert page.locator(".hl-title").inner_text().strip() == "Logga in"
    assert box(page, ".hl-lang")["y"] > box(page, "#kc-login")["y"]
    english = page.eval_on_selector(
        "#login-select-toggle", "s => [...s.options].find(o => o.value.endsWith('kc_locale=en')).value")
    page.select_option("#login-select-toggle", english)
    page.wait_for_selector("#kc-login")
    shot(page, "login-english-light-390")
    assert page.locator(".hl-title").inner_text().strip() == "Sign in"


@pytest.mark.parametrize("scheme,error", [("light", LIGHT_ERROR), ("dark", DARK_ERROR)])
def test_login_error_state(make_page, login_url, scheme, error):
    page = open_login(make_page, login_url, scheme=scheme)
    sign_in(page, "alice", "wrong-password")
    # keycloak.v2 shows bad credentials inline under the field, not as an alert.
    message = '.hl-content [id^="input-error-"] .kc-feedback-text'
    page.wait_for_selector(message)
    shot(page, f"login-error-{scheme}-390")
    assert style(page, message, "color") == error
    assert no_overflow(page)
    assert style(page, ".hl-shell", "border-top-width") == "0px"


def test_otp_page_in_frame(make_page, login_url):
    page = open_login(make_page, login_url, scheme="dark")
    sign_in(page, "alice")
    page.wait_for_selector("#otp")
    shot(page, "login-otp-dark-390")
    assert page.locator(".hl-header").count() == 1
    assert style(page, ".hl-rule", "background-color") == "rgb(216, 184, 94)"


def test_frame_on_other_pages(make_page, login_url):
    page = open_login(make_page, login_url)
    page.click('a[href*="reset-credentials"]')
    page.wait_for_selector("#username")
    assert page.locator(".hl-header").count() == 1

    page.goto(f"{BASE}/realms/{REALM}/protocol/openid-connect/auth?client_id=no-such-client"
              "&response_type=code&redirect_uri=http%3A%2F%2Fexample.invalid")
    shot(page, "login-errorpage-light-390")
    assert page.locator(".hl-header").count() == 1


def test_password_toggle_works(make_page, login_url):
    page = open_login(make_page, login_url)
    assert page.get_attribute("#password", "type") == "password"
    page.click('button[data-password-toggle]')
    assert page.get_attribute("#password", "type") == "text"


@pytest.mark.parametrize("scheme,background,ink", [
    ("light", "rgb(13, 27, 42)", "rgb(255, 255, 255)"),
    ("dark", "rgb(106, 160, 184)", "rgb(13, 27, 42)"),
])
def test_primary_button_uses_tokens(make_page, login_url, scheme, background, ink):
    page = open_login(make_page, login_url, scheme=scheme)
    assert style(page, "#kc-login", "background-color") == background
    assert style(page, "#kc-login", "color") == ink


@pytest.mark.parametrize("scheme,line", [("light", "rgb(213, 221, 230)"), ("dark", "rgb(37, 50, 63)")])
def test_fields_have_full_rounded_border(make_page, login_url, scheme, line):
    page = open_login(make_page, login_url, scheme=scheme)
    page.focus("#kc-login")  # nothing focused in the fields
    for field in ("#username", "#password"):
        control = f".pf-v5-c-form-control:has({field})"
        assert style(page, control, "border-top-color") == line, field
        assert style(page, control, "border-top-width") == "1px", field
        assert style(page, control, "border-top-left-radius") == "12px", field


def test_touch_targets(make_page, login_url):
    page = open_login(make_page, login_url)
    for field in ("#username", "#password"):
        assert box(page, field)["height"] >= 44, field
    assert box(page, "#kc-login")["height"] >= 48
