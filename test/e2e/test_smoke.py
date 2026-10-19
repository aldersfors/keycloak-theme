from conftest import BASE, REALM, origin, shot, sign_in, submit_otp


def test_login_page_uses_theme(page_desktop, login_url):
    css = {}
    page_desktop.on("response", lambda r: css.__setitem__(r.url, r.status) if r.url.endswith(".css") else None)
    response = page_desktop.goto(login_url("sv"))
    page_desktop.wait_for_load_state("networkidle")
    assert response.status == 200
    broken = {url: status for url, status in css.items() if status != 200}
    assert not broken, broken
    for shared in ("/common/halsingland/css/tokens.css", "/common/halsingland/css/fonts.css"):
        assert any(url.endswith(shared) for url in css), f"{shared} not loaded: {sorted(css)}"


def test_no_third_party_requests(make_page, login_url):
    """Login, OTP, account and admin pages only ever talk to Keycloak itself."""
    user = make_page()
    user.goto(login_url("sv"))
    sign_in(user, "alice")
    user.wait_for_selector("#otp")
    shot(user, "smoke-otp")
    submit_otp(user)
    user.wait_for_url(f"{BASE}/realms/{REALM}/account/**")
    user.wait_for_load_state("networkidle")

    admin = make_page()
    admin.goto(f"{BASE}/admin/{REALM}/console/")
    sign_in(admin, "admin")
    admin.wait_for_url(f"{BASE}/admin/{REALM}/console/**")
    admin.wait_for_load_state("networkidle")

    keycloak = origin(BASE)
    requested = [u for u in user.requested + admin.requested if u.startswith(("http://", "https://"))]
    assert requested, "no requests were recorded"
    foreign = sorted({u for u in requested if origin(u) != keycloak})
    assert not foreign, foreign
