# Contributing

1. Run `mise install`.
2. Add packages through `mise run new-package -- owner/repository` when Aqua can scaffold them.
3. Review the generated package definition and add verification metadata supported by the upstream release.
4. Run `mise run build`.
5. Run `mise run check`.
6. Commit both source fragments and generated outputs.

Do not hand-edit `registry.yaml` or `mise/registry.toml`.
