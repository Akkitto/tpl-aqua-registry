#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

require_command() {
  local -r command_name="$1"
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'error: required command not found: %s\n' "${command_name}" >&2
    exit 127
  fi
}

require_command git
require_command yq
require_command python3
require_command shellcheck
require_command actionlint

"${SCRIPT_DIR}/build.sh"

# Parse all YAML files with yq so malformed source/config files fail validation.
while IFS= read -r -d '' yaml_file; do
  yq '.' "${yaml_file}" >/dev/null
done < <(find "${REPO_ROOT}" -type f \( -name '*.yaml' -o -name '*.yml' \) -not -path '*/.git/*' -print0)

python3 -m py_compile "${SCRIPT_DIR}/render_mise.py"
python3 -m unittest discover -s "${REPO_ROOT}/tests" -p 'test_*.py'
shellcheck "${SCRIPT_DIR}"/*.sh
actionlint "${REPO_ROOT}/.github/workflows/"*.yaml

if git -C "${REPO_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "${REPO_ROOT}" diff --exit-code -- registry.yaml mise/registry.toml
fi
