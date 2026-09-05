#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
readonly CHECKSUM_FILE="${REPO_ROOT}/SHA256SUMS"

"${SCRIPT_DIR}/build.sh"

(
  cd -- "${REPO_ROOT}"
  sha256sum registry.yaml mise/registry.toml > "${CHECKSUM_FILE}"
)
