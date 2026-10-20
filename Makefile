JAR := dist/keycloak-theme-halsingland.jar
COMPOSE := docker compose -f preview/compose.yaml

# The Keycloak the preview and the browser tests run against: the version production runs.
# KEYCLOAK_VERSIONS are the versions the theme must work on, the next one included, so it can
# ship before the server upgrade. `make test-all` runs the suite against each.
KEYCLOAK_VERSION ?= 26.5.3
KEYCLOAK_VERSIONS := 26.5.3 26.8.1
export KEYCLOAK_VERSION

.PHONY: jar image test test-all test-jar test-image test-e2e preview preview-down clean

jar: $(JAR)

$(JAR): $(shell find META-INF theme -type f)
	@mkdir -p dist
	rm -f $@
	zip -q -r -X $@ META-INF theme -x '*.DS_Store'

image: jar
	docker build --load -f Containerfile -t ghcr.io/aldersfors/keycloak-theme:dev .

# Keycloak with the theme mounted (http://localhost:8080) and Mailpit (http://localhost:8025).
preview: jar
	$(COMPOSE) up -d --wait keycloak mailpit

preview-down:
	$(COMPOSE) down -v

test: test-jar test-e2e

test-all: test-jar
	@set -e; for v in $(KEYCLOAK_VERSIONS); do \
		echo "== Keycloak $$v"; \
		$(MAKE) --no-print-directory test-e2e KEYCLOAK_VERSION=$$v; \
	done

test-jar: jar
	bash test/jar_test.sh $(JAR)

# The scratch image holds exactly the JAR.
test-image: jar
	bash test/image_test.sh

# Restart Keycloak so it picks up the freshly built JAR (and the chosen version), then run the
# browser tests. Screenshots land in test/out/<version>/.
test-e2e: jar
	$(COMPOSE) up -d --wait --force-recreate keycloak mailpit
	$(COMPOSE) run --rm tests

clean:
	rm -rf dist test/out
