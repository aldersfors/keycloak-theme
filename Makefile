JAR := dist/keycloak-theme-halsingland.jar

.PHONY: jar test clean

jar: $(JAR)

$(JAR): $(shell find META-INF theme -type f)
	@mkdir -p dist
	rm -f $@
	zip -q -r -X $@ META-INF theme -x '*.DS_Store'

test: jar
	bash test/jar_test.sh $(JAR)

clean:
	rm -rf dist test/out
