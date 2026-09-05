# Package authoring

## Scaffold with Aqua

Prefer Aqua's generator over hand-writing GitHub Release definitions:

```text
mise run new-package -- owner/tool
```

If the executable name differs from the repository name:

```text
mise run new-package -- --command command-name owner/tool
```

By default, `aqua gr` inspects available release history. Use `--latest-only` only when deliberately supporting only the latest release:

```text
mise run new-package -- --latest-only owner/tool
```

Review the generated file before committing. Asset naming, historical release differences, checksum files, supported environments, and provenance options may require manual adjustment.

## Layout

The scaffolder writes:

```text
pkgs/owner/tool/registry.yaml
```

Nested package names are supported as deeper directories.

## Quality rules

- Prefer `github_release` for software distributed through GitHub Releases.
- Keep package names unique within the registry.
- Prefer deterministic, consistent release asset names upstream.
- Add checksum/provenance verification when upstream releases provide the required artifacts.
- Keep Aqua templates compact, e.g. `{{.OS}}`, not `{{ .OS }}`.
- Keep descriptions terse and without trailing punctuation.
- Do not edit the root `registry.yaml`; regenerate it.
