#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
declare -r SCRIPT_DIR
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
declare -r REPO_ROOT
declare -r CONFIG_FILE="${REPO_ROOT}/registry.config.yaml"

usage() {
  cat <<'USAGE'
Usage: scripts/configure.sh --owner OWNER --repo REPOSITORY [options]

Options:
  --owner OWNER              GitHub repository owner or organization
  --repo REPOSITORY          Registry repository name
  --display-name NAME        Human-readable registry name
  --description TEXT         Human-readable registry description
  --branch BRANCH            Default branch metadata (default is master)
  --public-url URL           Override the mise custom-registry URL
  --cache-ttl DURATION       mise Aqua registry cache TTL, e.g. 1w or 1h
  --alias-strategy STRATEGY  basename or none
  -h, --help                 Show this help
USAGE
}

if ! command -v yq >/dev/null 2>&1; then
  printf '%s\n' 'error: yq is required; run this through mise run configure -- ... or install yq on PATH' >&2
  exit 127
fi

owner=''
repo=''
display_name=''
description=''
branch=''
public_url=''
cache_ttl=''
alias_strategy=''

while (( $# > 0 )); do
  case "$1" in
    --owner) owner="${2:?missing value for --owner}"; shift 2 ;;
    --repo) repo="${2:?missing value for --repo}"; shift 2 ;;
    --display-name) display_name="${2:?missing value for --display-name}"; shift 2 ;;
    --description) description="${2:?missing value for --description}"; shift 2 ;;
    --branch) branch="${2:?missing value for --branch}"; shift 2 ;;
    --public-url) public_url="${2:?missing value for --public-url}"; shift 2 ;;
    --cache-ttl) cache_ttl="${2:?missing value for --cache-ttl}"; shift 2 ;;
    --alias-strategy) alias_strategy="${2:?missing value for --alias-strategy}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'error: unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "${owner}" || -z "${repo}" ]]; then
  printf 'error: --owner and --repo are required\n' >&2
  usage >&2
  exit 2
fi

OWNER="${owner}" REPO="${repo}" yq -i \
  '.repository.owner = strenv(OWNER) | .repository.name = strenv(REPO)' \
  "${CONFIG_FILE}"

if [[ -n "${display_name}" ]]; then
  DISPLAY_NAME="${display_name}" yq -i '.registry.display_name = strenv(DISPLAY_NAME)' "${CONFIG_FILE}"
fi
if [[ -n "${description}" ]]; then
  DESCRIPTION="${description}" yq -i '.registry.description = strenv(DESCRIPTION)' "${CONFIG_FILE}"
fi
if [[ -n "${branch}" ]]; then
  BRANCH="${branch}" yq -i '.repository.default_branch = strenv(BRANCH)' "${CONFIG_FILE}"
fi
if [[ -n "${public_url}" ]]; then
  PUBLIC_URL="${public_url}" yq -i '.repository.public_url = strenv(PUBLIC_URL)' "${CONFIG_FILE}"
fi
if [[ -n "${cache_ttl}" ]]; then
  CACHE_TTL="${cache_ttl}" yq -i '.mise.registry_cache_ttl = strenv(CACHE_TTL)' "${CONFIG_FILE}"
fi
if [[ -n "${alias_strategy}" ]]; then
  case "${alias_strategy}" in
    basename|none) ;;
    *) printf 'error: --alias-strategy must be basename or none\n' >&2; exit 2 ;;
  esac
  ALIAS_STRATEGY="${alias_strategy}" yq -i '.mise.alias_strategy = strenv(ALIAS_STRATEGY)' "${CONFIG_FILE}"
fi

"${SCRIPT_DIR}/build.sh"
