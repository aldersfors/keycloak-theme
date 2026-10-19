# Only the theme JAR. Keycloak mounts this image as a Kubernetes image volume at
# /opt/keycloak/providers, so nothing else (no shell, no copy tool) is needed.
FROM scratch
COPY dist/keycloak-theme-halsingland.jar /keycloak-theme-halsingland.jar
