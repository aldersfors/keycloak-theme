#!/usr/bin/env bash
# Checks the built theme JAR: manifest, shared resources, fonts and licences.
set -euo pipefail

JAR=${1:-dist/keycloak-theme-halsingland.jar}
fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f $JAR ]] || fail "$JAR does not exist (run make jar)"

listing=$(unzip -Z1 "$JAR")
has() { grep -qxF "$1" <<<"$listing" || fail "missing $1"; }

manifest=$(unzip -p "$JAR" META-INF/keycloak-themes.json) || fail "missing META-INF/keycloak-themes.json"
jq -e '.themes | length == 1' <<<"$manifest" >/dev/null || fail "manifest must declare exactly one theme"
jq -e '.themes[0].name == "halsingland"' <<<"$manifest" >/dev/null || fail "theme name must be halsingland"
jq -e '.themes[0].types | sort == ["account","admin","common","email","login"]' <<<"$manifest" >/dev/null \
  || fail "theme types must be exactly common, login, account, admin, email"

common=theme/halsingland/common/resources
has "$common/img/logo.svg"
has "$common/css/tokens.css"
has "$common/css/fonts.css"

woff2=$(grep -c "^$common/fonts/.*\.woff2$" <<<"$listing" || true)
[[ $woff2 -eq 5 ]] || fail "expected 5 woff2 fonts, found $woff2"
ofl=$(grep -c "^$common/fonts/OFL-.*\.txt$" <<<"$listing" || true)
[[ $ofl -eq 2 ]] || fail "expected 2 OFL licence files, found $ofl"

if grep -q 'node_modules' <<<"$listing"; then fail "JAR contains node_modules"; fi

echo "PASS: $JAR"
