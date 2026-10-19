JAR := dist/keycloak-theme-halsingland.jar
COMPOSE := docker compose -f preview/compose.yaml

.PHONY: jar image test test-jar test-e2e preview preview-down clean

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

test-jar: jar
	bash test/jar_test.sh $(JAR)

# Restart Keycloak so it picks up the freshly built JAR, then run the browser tests.
test-e2e: jar
	$(COMPOSE) up -d --wait --force-recreate keycloak mailpit
	$(COMPOSE) run --rm tests

clean:
	rm -rf dist test/out
