#!/usr/bin/env bash
set -euo pipefail

readonly REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/aqua-registry-empty-test.XXXXXXXX")"
trap 'rm -rf -- "${TEMP_ROOT}"' EXIT

mkdir -p -- "${TEMP_ROOT}/scripts"
cp -- "${REPO_ROOT}/registry.config.yaml" "${TEMP_ROOT}/registry.config.yaml"
cp -- "${REPO_ROOT}/scripts/build.sh" "${TEMP_ROOT}/scripts/build.sh"
cp -- "${REPO_ROOT}/scripts/configure.sh" "${TEMP_ROOT}/scripts/configure.sh"
cp -- "${REPO_ROOT}/scripts/render_mise.py" "${TEMP_ROOT}/scripts/render_mise.py"
chmod +x -- "${TEMP_ROOT}/scripts/build.sh" "${TEMP_ROOT}/scripts/configure.sh"

# Intentionally do not create TEMP_ROOT/pkgs. A fresh repository with no package
# definitions is a valid empty registry and configure must still succeed.
"${TEMP_ROOT}/scripts/configure.sh" \
  --owner ExampleOrg \
  --repo custom-aqua-registry \
  --display-name Master

[[ "$(yq -r '.repository.owner' "${TEMP_ROOT}/registry.config.yaml")" == 'ExampleOrg' ]]
[[ "$(yq -r '.repository.name' "${TEMP_ROOT}/registry.config.yaml")" == 'custom-aqua-registry' ]]
[[ "$(yq -r '.registry.display_name' "${TEMP_ROOT}/registry.config.yaml")" == 'Master' ]]
[[ "$(yq -r '.packages | length' "${TEMP_ROOT}/registry.yaml")" == '0' ]]
grep -Fq 'aqua.registries = ["https://github.com/ExampleOrg/custom-aqua-registry"]' \
  "${TEMP_ROOT}/mise/registry.toml"
