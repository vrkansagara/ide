#!/usr/bin/env bash
# ==============================================================================
#  PHP Multi-Version Installation Script
# ==============================================================================
#  Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
#  Version    : 2.0.0
#  Purpose    : Install multiple PHP versions with extensions on
#               Debian/Ubuntu systems using Ondrej Sury's repository.
#  Supports   : Ubuntu (Ondrej PPA), Debian (packages.sury.org), WSL
#
#  Usage: ./php-installation.sh [OPTIONS]
#
#  Options:
#    -v, --verbose           Enable verbose output (set -x)
#    -n, --dry-run           Show commands without executing
#    --versions VERS         Comma-separated versions to install
#                            Default: 7.4,8.0,8.1,8.2,8.3,8.4
#                            Example: --versions "8.2,8.3"
#    --skip-versions VERS    Comma-separated versions to skip
#                            Example: --skip-versions "7.4,8.0"
#    --no-fpm                Skip php-fpm installation
#    --log FILE              Log file path (default: /var/log/php-install.log)
#    -h, --help              Show this help
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_VERSION="2.0.0"
readonly DEFAULT_LOG="/var/log/php-install.log"
readonly SUPPORTED_VERSIONS=(7.4 8.0 8.1 8.2 8.3 8.4)

# Real apt package name suffixes (maps to php${VER}-${EXT})
# Verified against packages.sury.org / ondrej/php PPA.
readonly COMMON_EXTENSIONS=(
  bcmath
  bz2
  curl
  dev
  gd
  gmp
  intl
  mbstring
  mysql    # provides mysqli + pdo_mysql
  opcache
  pgsql    # provides pgsql + pdo_pgsql
  soap
  sqlite3
  tidy
  xml      # provides dom, simplexml, xmlreader, xmlwriter, xsl
  xsl
  zip
)

# Optional — expected to be absent for some versions; failure is silently skipped.
readonly OPTIONAL_EXTENSIONS=(
  exif
  imagick
  memcached
  msgpack
  redis
  xdebug
)

# ------------------------------------------------------------------------------
# Mutable state
# ------------------------------------------------------------------------------
DRY_RUN=false
VERBOSE=false
INSTALL_FPM=true
LOG_FILE="${DEFAULT_LOG}"
VERSIONS_TO_INSTALL=("${SUPPORTED_VERSIONS[@]}")
VERSIONS_TO_SKIP=()
SUDO_CMD=()
FAILURES=()
SUCCESSES=()

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------
log() {
  local level="$1"; shift
  local ts; ts="$(date '+%Y-%m-%d %H:%M:%S')"
  local line="[${ts}] [${level}] $*"
  echo "${line}" | tee -a "${LOG_FILE}"
}

log_info()    { log "INFO " "$@"; }
log_warn()    { log "WARN " "$@" >&2; }
log_error()   { log "ERROR" "$@" >&2; }
log_ok()      { log "OK   " "$@"; }
log_debug()   { [[ "${VERBOSE}" == true ]] && log "DEBUG" "$@" || true; }
log_sep()     { log_info "$(printf '%.0s-' {1..60})"; }

# ------------------------------------------------------------------------------
# Error trap
# ------------------------------------------------------------------------------
on_error() {
  local code=$? line="${BASH_LINENO[0]}"
  log_error "Unexpected failure at line ${line} (exit ${code})."
  print_summary
  exit "${code}"
}
trap on_error ERR

# ------------------------------------------------------------------------------
# Usage
# ------------------------------------------------------------------------------
usage() {
  grep '^#  ' "${BASH_SOURCE[0]}" | sed 's/^#  //'
}

# ------------------------------------------------------------------------------
# Argument parsing
# ------------------------------------------------------------------------------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--verbose)
        VERBOSE=true
        set -x
        shift ;;
      -n|--dry-run)
        DRY_RUN=true
        shift ;;
      --versions)
        IFS=',' read -ra VERSIONS_TO_INSTALL <<< "$2"
        shift 2 ;;
      --skip-versions)
        IFS=',' read -ra VERSIONS_TO_SKIP <<< "$2"
        shift 2 ;;
      --no-fpm)
        INSTALL_FPM=false
        shift ;;
      --log)
        LOG_FILE="$2"
        shift 2 ;;
      -h|--help)
        usage
        exit 0 ;;
      *)
        log_error "Unknown option: $1"
        usage
        exit 1 ;;
    esac
  done
}

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------
is_skipped() {
  local ver="$1"
  if [[ ${#VERSIONS_TO_SKIP[@]} -eq 0 ]]; then return 1; fi
  local v; for v in "${VERSIONS_TO_SKIP[@]}"; do
    [[ "${ver}" == "${v}" ]] && return 0
  done
  return 1
}

# Run a command or print it in dry-run mode.
run() {
  if [[ "${DRY_RUN}" == true ]]; then
    log_info "[DRY-RUN] $*"
    return 0
  fi
  log_debug "Running: $*"
  "$@"
}

# apt-get wrapper: always quiet, log output to file, non-interactive.
apt_install() {
  DEBIAN_FRONTEND=noninteractive \
    run "${SUDO_CMD[@]}" apt-get install --no-install-recommends --yes "$@" \
      >> "${LOG_FILE}" 2>&1
}

# ------------------------------------------------------------------------------
# Setup
# ------------------------------------------------------------------------------
setup_logging() {
  local dir; dir="$(dirname "${LOG_FILE}")"
  if ! mkdir -p "${dir}" 2>/dev/null || ! touch "${LOG_FILE}" 2>/dev/null; then
    LOG_FILE="/tmp/php-install-$$.log"
    echo "Warning: Cannot write to default log; using ${LOG_FILE}" >&2
    touch "${LOG_FILE}"
  fi
}

check_prerequisites() {
  log_info "Checking prerequisites..."

  if [[ "$(id -u)" -eq 0 ]]; then
    log_info "Running as root."
  elif command -v sudo &>/dev/null; then
    SUDO_CMD=(sudo)
    log_info "Running as non-root; will use sudo."
  else
    log_error "Root or sudo is required."
    exit 1
  fi

  local tool; for tool in apt-get curl lsb_release; do
    if ! command -v "${tool}" &>/dev/null; then
      log_error "Required tool not found: ${tool}"
      exit 1
    fi
  done

  local os_id
  os_id="$(grep -oP '(?<=^ID=).+' /etc/os-release 2>/dev/null | tr -d '"' || echo unknown)"
  log_info "Detected OS: ${os_id}"
  if [[ ! "${os_id}" =~ ^(debian|ubuntu|raspbian|linuxmint|pop)$ ]]; then
    log_warn "OS '${os_id}' is not officially supported. Proceeding anyway."
  fi

  log_ok "Prerequisites OK."
}

# ------------------------------------------------------------------------------
# Repository setup
# ------------------------------------------------------------------------------
add_php_repository() {
  log_sep
  log_info "Configuring PHP repository..."

  local os_id uname_out
  os_id="$(grep -oP '(?<=^ID=).+' /etc/os-release 2>/dev/null | tr -d '"' || echo unknown)"
  uname_out="$(uname -r 2>/dev/null || true)"

  if [[ "${os_id}" == "ubuntu" ]] || echo "${uname_out}" | grep -qi "microsoft"; then
    # Ubuntu / WSL: use Ondrej's PPA
    log_info "Ubuntu/WSL detected — using ppa:ondrej/php"
    apt_install software-properties-common
    run "${SUDO_CMD[@]}" add-apt-repository --yes ppa:ondrej/php
  else
    # Debian: use packages.sury.org with modern signed-by keyring
    log_info "Debian detected — using packages.sury.org"
    local codename keyring_path="/usr/share/keyrings/php-sury.gpg"
    codename="$(lsb_release -sc)"

    run "${SUDO_CMD[@]}" bash -c \
      "curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o '${keyring_path}'"
    run "${SUDO_CMD[@]}" chmod 644 "${keyring_path}"
    run "${SUDO_CMD[@]}" bash -c \
      "echo 'deb [signed-by=${keyring_path}] https://packages.sury.org/php/ ${codename} main' \
       > /etc/apt/sources.list.d/php-sury.list"
  fi

  run "${SUDO_CMD[@]}" apt-get update -qq
  log_ok "PHP repository configured."
}

# ------------------------------------------------------------------------------
# Package installation
# ------------------------------------------------------------------------------
install_base_packages() {
  log_sep
  log_info "Installing prerequisite system packages..."

  DEBIAN_FRONTEND=noninteractive \
    run "${SUDO_CMD[@]}" apt-get -qq autoremove --yes >> "${LOG_FILE}" 2>&1 || true
  DEBIAN_FRONTEND=noninteractive \
    run "${SUDO_CMD[@]}" apt-get -qq install --fix-broken --yes >> "${LOG_FILE}" 2>&1 || true

  apt_install apt-transport-https ca-certificates curl gnupg lsb-release php-pear
  log_ok "System prerequisites installed."
}

# Returns 0 if package was installed, 1 if unavailable (silently logged).
try_install_extension() {
  local pkg="$1"
  if [[ "${DRY_RUN}" == true ]]; then
    log_info "[DRY-RUN] Would install: ${pkg}"
    return 0
  fi
  if DEBIAN_FRONTEND=noninteractive \
       "${SUDO_CMD[@]}" apt-get install --no-install-recommends --yes "${pkg}" \
       >> "${LOG_FILE}" 2>&1; then
    log_ok "  + ${pkg}"
    return 0
  else
    log_warn "  ~ ${pkg} (not available — skipped)"
    return 1
  fi
}

install_php_version() {
  local ver="$1"
  log_sep
  log_info "Installing PHP ${ver}..."

  # Base packages must succeed; failure aborts this version.
  if ! apt_install "php${ver}" "php${ver}-cli" "php${ver}-common"; then
    log_error "Failed to install base PHP ${ver} — skipping."
    FAILURES+=("php${ver}(base)")
    return 1
  fi

  local missing=()

  if [[ "${INSTALL_FPM}" == true ]]; then
    try_install_extension "php${ver}-fpm" || missing+=(fpm)
  fi

  local ext
  for ext in "${COMMON_EXTENSIONS[@]}"; do
    try_install_extension "php${ver}-${ext}" || missing+=("${ext}")
  done

  for ext in "${OPTIONAL_EXTENSIONS[@]}"; do
    try_install_extension "php${ver}-${ext}" || true   # optional: always continue
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    log_warn "PHP ${ver}: unavailable common extensions: ${missing[*]}"
    FAILURES+=("php${ver}[${missing[*]}]")
  fi

  SUCCESSES+=("php${ver}")
  log_ok "PHP ${ver} installed."
}

# ------------------------------------------------------------------------------
# Configure update-alternatives (non-interactive)
# ------------------------------------------------------------------------------
configure_alternatives() {
  log_sep
  log_info "Configuring PHP alternatives..."

  local priority=10
  local highest=""

  local ver
  for ver in "${VERSIONS_TO_INSTALL[@]}"; do
    is_skipped "${ver}" && continue
    if [[ ! -f "/usr/bin/php${ver}" ]]; then continue; fi

    run "${SUDO_CMD[@]}" update-alternatives --install \
      /usr/bin/php php "/usr/bin/php${ver}" "${priority}" \
      --slave /usr/bin/php-config php-config "/usr/bin/php-config${ver}" \
      --slave /usr/bin/phpize    phpize    "/usr/bin/phpize${ver}" \
      2>/dev/null || true

    priority=$(( priority + 10 ))
    highest="${ver}"
  done

  if [[ -n "${highest}" && -f "/usr/bin/php${highest}" ]]; then
    run "${SUDO_CMD[@]}" update-alternatives --set php "/usr/bin/php${highest}" || true
    log_ok "Default PHP set to: ${highest}"
  else
    log_warn "No PHP binaries found for update-alternatives."
  fi
}

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
print_summary() {
  log_sep
  log_info "=== Installation Summary ==="
  if [[ ${#SUCCESSES[@]} -gt 0 ]]; then
    log_ok  "Versions processed : ${SUCCESSES[*]}"
  fi
  if [[ ${#FAILURES[@]} -gt 0 ]]; then
    log_warn "Unavailable pkgs   : ${FAILURES[*]}"
  fi
  local active
  active="$(php --version 2>/dev/null | head -1 || echo '(php not in PATH)')"
  log_info "Active PHP         : ${active}"
  log_info "Full log           : ${LOG_FILE}"
  log_sep
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
main() {
  parse_args "$@"
  setup_logging

  log_sep
  log_info "${SCRIPT_NAME} v${SCRIPT_VERSION}"
  log_info "Started : $(date)"
  [[ "${DRY_RUN}" == true ]] && log_warn "DRY-RUN mode — no changes will be made."
  log_sep

  check_prerequisites
  install_base_packages
  add_php_repository

  local ver
  for ver in "${VERSIONS_TO_INSTALL[@]}"; do
    if is_skipped "${ver}"; then
      log_info "Skipping PHP ${ver} (in skip list)."
      continue
    fi
    install_php_version "${ver}" || true
  done

  configure_alternatives
  print_summary

  log_info "${SCRIPT_NAME} ..... [DONE]"
}

main "$@"
