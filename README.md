# keycloak-theme

The `halsingland` Keycloak theme for the aldersfors apps: login, account, admin and email,
in plain FreeMarker templates and CSS. No React, no JavaScript framework, no Node build.
Colours follow the device's light or dark setting and use matlistan's palette; Swedish and
English.

```sh
make jar    # dist/keycloak-theme-halsingland.jar
make test   # checks the JAR
```

## Layout

| Path | What it holds |
|------|---------------|
| `theme/halsingland/common/resources` | Colour tokens, bundled fonts, the Delsbo logo; imported by every type |
| `META-INF/keycloak-themes.json` | Declares the theme and its types to Keycloak |

## Fonts

Bundled so no page loads anything from a font CDN. Both are under the SIL Open Font
Licence 1.1 (`fonts/OFL-*.txt`).

| File | Source | sha256 |
|------|--------|--------|
| `geist-400.woff2` | [vercel/geist-font v1.8.1](https://github.com/vercel/geist-font/releases/tag/v1.8.1) `Geist-Regular.woff2` | `ead06aafe33c44d6854b7c56708a71d2c11483bda2e5d237f5ec1eb24414f2db` |
| `geist-500.woff2` | vercel/geist-font v1.8.1 `Geist-Medium.woff2` | `43cf7f2d68ca17c5e36e7a4a4d76a56b508a5dd0da71680026c8fa474f7739f6` |
| `geist-700.woff2` | vercel/geist-font v1.8.1 `Geist-Bold.woff2` | `81ada835c8ada0e3c0ad1d80a96efd07aa05e1d170d070f7771ec8637862a6f6` |
| `bricolage-grotesque-700.woff2` | [aldersfors/matlistan@0f24955](https://github.com/aldersfors/matlistan/tree/0f24955cc6692cf7b5773338ab6bceeeba023ead/internal/web/static/fonts) | `4c373ce3c1cca41c864eb3e27c059a59fc6310547ab9c9b6cd780d387ba24206` |
| `bricolage-grotesque-800.woff2` | aldersfors/matlistan@0f24955 | `3e1b5f0a56ee995b7c1445bc54e6ec98c5dffb585ef5c4baf86731cf68e27c61` |

## Licence

Apache-2.0, like the other aldersfors repos; see [LICENSE](LICENSE). The fonts keep their own OFL licence.
