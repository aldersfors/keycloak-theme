import pytest

from conftest import BASE, DESKTOP, PHONE, REALM, shot, sign_in, submit_otp

NAVY = "rgb(13, 27, 42)"
PRIMARY = {"light": "rgb(13, 27, 42)", "dark": "rgb(106, 160, 184)"}


def open_console(make_page, url, user, viewport, scheme, otp=False):
    page = make_page(viewport, scheme)
    css = {}
    page.on("response", lambda r: css.__setitem__(r.url, r.status) if r.url.endswith(".css") else None)
    page.goto(url)
    sign_in(page, user)
    if otp:
        page.wait_for_selector("#otp")
        submit_otp(page)
    page.wait_for_selector(".pf-v5-c-masthead img")
    page.wait_for_load_state("networkidle")
    page.css = css
    return page


def primary_colour(page):
    return page.evaluate("""() => {
        const probe = document.createElement('span');
        probe.style.color = 'var(--pf-v5-global--primary-color--100)';
        document.body.append(probe);
        const value = getComputedStyle(probe).color;
        probe.remove();
        return value;
    }""")


def assert_styled(page, stylesheet, scheme):
    errors = page.locator(".pf-v5-c-empty-state.pf-m-xl, [data-testid='error-page']")
    assert errors.count() == 0, "console rendered its error page"
    loaded = [url for url, status in page.css.items() if url.endswith(stylesheet) and status == 200]
    assert loaded, f"{stylesheet} not loaded: {sorted(page.css)}"
    logo = page.locator(".pf-v5-c-masthead img").first
    assert "logo-gold.svg" in logo.get_attribute("src")
    assert logo.evaluate("img => img.complete && img.naturalWidth > 0"), "logo did not load"
    masthead = page.eval_on_selector(".pf-v5-c-masthead", "el => getComputedStyle(el).backgroundColor")
    assert masthead == NAVY
    assert primary_colour(page) == PRIMARY[scheme]
    font = page.eval_on_selector("body", "el => getComputedStyle(el).fontFamily")
    assert font.startswith('"Geist"') or font.startswith("Geist"), font


PAGE = {"light": "rgb(255, 255, 255)", "dark": "rgb(13, 27, 42)"}


@pytest.mark.parametrize("scheme", ["light", "dark"])
def test_account_console_styled(make_page, scheme):
    page = open_console(make_page, f"{BASE}/realms/{REALM}/account/", "alice", DESKTOP, scheme, otp=True)
    shot(page, f"account-{scheme}-1280")
    assert_styled(page, "/account/halsingland/css/account.css", scheme)
    save = page.locator(".pf-v5-c-button.pf-m-primary").first
    assert save.evaluate("el => getComputedStyle(el).backgroundColor") == PRIMARY[scheme]
    main = page.eval_on_selector(".pf-v5-c-page__main-section", "el => getComputedStyle(el).backgroundColor")
    assert main == PAGE[scheme]
    painted = page.eval_on_selector(".pf-v5-c-masthead", """masthead => [...masthead.querySelectorAll('*')]
        .filter(el => !el.closest('button, input, select, img, .pf-v5-c-avatar, .pf-v5-c-menu-toggle'))
        .map(el => [el.className, getComputedStyle(el).backgroundColor])
        .filter(([, bg]) => bg !== 'rgba(0, 0, 0, 0)' && bg !== 'rgb(13, 27, 42)')""")
    assert not painted, f"masthead parts not navy: {painted}"


def test_account_console_phone(make_page):
    page = open_console(make_page, f"{BASE}/realms/{REALM}/account/", "alice", PHONE, "light", otp=True)
    shot(page, "account-light-390")
    assert page.evaluate("document.documentElement.scrollWidth <= document.documentElement.clientWidth")


@pytest.mark.parametrize("scheme", ["light", "dark"])
def test_admin_console_styled(make_page, scheme):
    page = open_console(make_page, f"{BASE}/admin/{REALM}/console/", "admin", DESKTOP, scheme)
    shot(page, f"admin-{scheme}-1280")
    assert_styled(page, "/admin/halsingland/css/admin.css", scheme)
