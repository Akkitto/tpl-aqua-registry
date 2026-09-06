# Changelog

All notable changes to this template are documented here.

## 1.0.5 - 2026-09-06

### Fixed

- Make all mise shell tasks invoke Bash explicitly so CI does not depend on POSIX executable bits.
- Make shell-to-shell calls use `bash` explicitly, including build and empty-registry validation paths.
- Add regression coverage simulating scripts with mode `0644`, matching Windows/NTFS or template-copy workflows that can lose executable metadata.
- Keep executable bits in the Git index where supported while making them non-essential for correctness.

## 1.0.4 - 2026-09-06

### Fixed

- Ensure `tests/test-empty-registry.sh` uses ShellCheck-safe assignment followed by `declare -r` for command-derived readonly values.
- Update GitHub Actions checkout from `actions/checkout@v4` to current `actions/checkout@v7`, removing the Node 20 deprecation warning.

## 1.0.3 - 2026-09-06

- Make all repository shell scripts pass ShellCheck without broad rule suppression.
- Preserve command-substitution exit status before marking derived values readonly, resolving SC2155 correctly.
- Use expansion-safe quoting for intentional yq expressions, schema literals, and diagnostic text, resolving SC2016 without disabling it.
- Keep the existing ShellCheck CI gate as regression protection for all shell scripts and shell tests.

## 1.0.2 - 2026-09-06

- Fix first-run configuration when the repository contains no `pkgs/` directory yet.
- Treat zero package definitions as a valid empty registry and generate `packages: []`.
- Add a tracked `pkgs/README.md` so fresh clones expose the intended package-source layout.
- Add regression coverage for the empty-registry build invariant.

## 1.0.1 - 2026-09-06

- Fix fresh-clone bootstrap failure caused by installing the Aqua CLI through mise's Aqua backend.
- Scope repository tools to the tasks that require them, so `configure` does not resolve unrelated tooling.
- Bootstrap Aqua, yq, ShellCheck, and actionlint directly from GitHub Releases through mise's built-in GitHub backend.
- Add regression tests for the bootstrap-safe mise task configuration.

## 1.0.0 - 2026-09-05

- Add generic custom Aqua registry repository configuration.
- Add per-package source layout with deterministic aggregate registry generation.
- Add prefix-free mise alias generation with collision detection, overrides, and exclusions.
- Add Aqua-native package scaffolding through `aqua gr`.
- Add CI validation and SemVer-tagged registry release workflow.
- Add Aqua and mise consumer documentation.
- Include full Git history in the source distribution.
