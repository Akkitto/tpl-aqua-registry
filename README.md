# Generic Aqua Registry Template

A reusable repository template for maintaining a custom Aqua registry and exposing the same packages through natural, prefix-free mise names.

The repository intentionally separates editable package definitions from generated distribution files:

```text
.
├── registry.config.yaml
├── registry.yaml                     # generated aggregate consumed by Aqua/mise
├── pkgs/
│   └── <owner>/<repository>/
│       └── registry.yaml             # editable Aqua package definition
├── mise/
│   └── registry.toml                 # generated custom-registry + aliases fragment
├── scripts/
├── docs/
└── .github/workflows/
```

## Design goals

- Generic: no dependency on a specific owner, organization, repository name, or package namespace.
- Aqua-native: package definitions are standard Aqua Registry Configuration and are scaffolded with `aqua gr`.
- mise-friendly: generated `[tool_alias]` entries provide `mise use tool@latest` rather than requiring `aqua:owner/tool` in daily use.
- Safe generation: duplicate Aqua package names and alias collisions fail the build.
- Deterministic: package fragments are sorted by Aqua package name before publishing.
- Reviewable: generated consumer files are committed and CI verifies that they match their sources.
- Versionable: SemVer Git tags provide immutable registry refs for Aqua consumers.

## Bootstrap

Install mise and trust this checkout according to your normal mise trust policy. Repository tools are task-scoped and are installed automatically when their task runs, so no separate bootstrap install is required.

Configure the repository once:

```text
mise run configure -- \
  --owner your-github-owner \
  --repo aqua-registry \
  --display-name "My Aqua Registry"
```

Equivalent settings can be edited directly in `registry.config.yaml`.

To pre-install every task-scoped tool, for example for CI images or offline preparation, use:

```text
mise install --include-task-tools
```

Bootstrap tools intentionally use mise's direct `github:` backend. In particular, the Aqua CLI is never installed through the Aqua backend, avoiding a dependency cycle before any Aqua registry is available.

## Add a package

Use Aqua's own generator:

```text
mise run new-package -- owner/tool
```

If the executable differs from the repository name:

```text
mise run new-package -- --command executable owner/tool
```

The package is written to `pkgs/owner/tool/registry.yaml`, after which the aggregate registry and mise aliases are regenerated.

Review Aqua's generated definition before committing. The generator is intentionally treated as a scaffold, not blindly trusted output.

## Configure aliases

With the default `basename` strategy:

```text
owner/alpha -> alpha
other/beta -> beta
```

Override individual packages when desired:

```yaml
mise:
  alias_strategy: basename
  alias_overrides:
    owner/long-repository-name: shortname
  alias_excludes:
    - owner/internal-helper
```

A collision such as `owner/tool` plus `another/tool` fails generation until one is overridden or excluded.

## Validate

```text
mise run check
```

Validation rebuilds the generated files, parses repository YAML, checks Python syntax, runs ShellCheck, runs actionlint, and fails when committed generated outputs are stale.

## Publish

Commit all generated output, create a SemVer tag, and push it:

```text
git tag v1.0.0
git push origin v1.0.0
```

The release workflow validates the tagged tree and publishes:

```text
registry.yaml
mise/registry.toml
SHA256SUMS
```

The tag itself is the immutable registry version Aqua consumers should reference.

## Consume through mise

Install the generated fragment as, for example:

```text
~/.config/mise/conf.d/50-custom-aqua-registry.toml
```

Then users can run:

```text
mise use -g tool@latest
```

rather than:

```text
mise use -g aqua:owner/tool@latest
```

See `docs/consumer-mise.md` and `docs/consumer-aqua.md` for details.

## Upstream references

- Aqua custom registries: https://aquaproj.github.io/docs/develop-registry/
- Aqua Registry Configuration: https://aquaproj.github.io/docs/reference/registry-config/
- Aqua registry style guide: https://aquaproj.github.io/docs/develop-registry/registry-style-guide/
- mise Aqua backend: https://mise.jdx.dev/dev-tools/backends/aqua
- mise configuration hierarchy: https://mise.jdx.dev/configuration.html

## Licence
Copyright © 2026  [Daniel Braniewski](https://brani.dev/)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.