#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

usage() {
  cat <<'USAGE'
Usage: scripts/new-package.sh [--command COMMAND] [--latest-only] OWNER/REPOSITORY[/SUBPATH]

Scaffolds an Aqua package definition with upstream `aqua gr`, stores it under
pkgs/<package>/registry.yaml, then regenerates the aggregate registry.

Options:
  --command COMMAND  Executable name when it differs from the repository name
  --latest-only      Ask aqua gr to inspect only the latest release (-l 1)
  -h, --help         Show this help
USAGE
}

if ! command -v aqua >/dev/null 2>&1; then
  printf 'error: aqua is required; run `mise install` first\n' >&2
  exit 127
fi

command_name=''
latest_only='false'
package=''

while (( $# > 0 )); do
  case "$1" in
    --command) command_name="${2:?missing value for --command}"; shift 2 ;;
    --latest-only) latest_only='true'; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) printf 'error: unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    *)
      if [[ -n "${package}" ]]; then
        printf 'error: only one package may be scaffolded at a time\n' >&2
        exit 2
      fi
      package="$1"
      shift
      ;;
  esac
done

if [[ -z "${package}" || "${package}" != */* || "${package}" == /* || "${package}" == *'..'* ]]; then
  printf 'error: package must be a safe OWNER/REPOSITORY[/SUBPATH] path\n' >&2
  exit 2
fi

readonly DESTINATION_DIR="${REPO_ROOT}/pkgs/${package}"
readonly DESTINATION_FILE="${DESTINATION_DIR}/registry.yaml"
if [[ -e "${DESTINATION_FILE}" ]]; then
  printf 'error: package definition already exists: %s\n' "${DESTINATION_FILE}" >&2
  exit 1
fi

mkdir -p -- "${DESTINATION_DIR}"

generator_args=()
if [[ -n "${command_name}" ]]; then
  generator_args+=( -cmd "${command_name}" )
fi
if [[ "${latest_only}" == 'true' ]]; then
  generator_args+=( -l 1 )
fi

{
  printf '%s\n' '# yaml-language-server: $schema=https://raw.githubusercontent.com/aquaproj/aqua/main/json-schema/registry.json'
  aqua gr "${generator_args[@]}" "${package}"
} > "${DESTINATION_FILE}"

"${SCRIPT_DIR}/build.sh"
printf 'created %s\n' "${DESTINATION_FILE}"
