#!/usr/bin/env bash
# Checks the scratch image holds exactly the theme JAR. Exports the image's own filesystem
# (docker build -o type=local) instead of `docker create` + `docker export`: a scratch image
# has no command to create a container from, and an exported container also carries the
# runtime's files (.dockerenv, etc/hosts, ...).
set -euo pipefail

out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT

docker build -q -f Containerfile -o "type=local,dest=$out" . >/dev/null
files=$(cd "$out" && find . -type f | sed 's|^\./||' | sort)

if [[ $files != "keycloak-theme-halsingland.jar" ]]; then
  echo "FAIL: image should hold only keycloak-theme-halsingland.jar, found:" >&2
  echo "$files" >&2
  exit 1
fi
echo "PASS: image holds only keycloak-theme-halsingland.jar"
