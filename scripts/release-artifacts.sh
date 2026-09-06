#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
declare -r SCRIPT_DIR
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
declare -r REPO_ROOT
declare -r CHECKSUM_FILE="${REPO_ROOT}/SHA256SUMS"

bash "${SCRIPT_DIR}/build.sh"

(
  cd -- "${REPO_ROOT}"
  sha256sum registry.yaml mise/registry.toml > "${CHECKSUM_FILE}"
)
