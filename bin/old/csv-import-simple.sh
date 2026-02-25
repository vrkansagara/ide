#!/usr/bin/env bash
# ==============================================================================
# csv-import-simple.sh — simple CSV import into MySQL without credentials file
# ==============================================================================
# Maintainer : Vallabhdas Kansagara <vrkansagara@gmail.com> — @vrkansagara
# Version    : 2.0.0

set -o errexit
set -o pipefail
set -o nounset

readonly VERSION="2.0.0"
readonly PROGNAME="${0##*/}"
VERBOSE=0
SUDO_CMD=""

_init_colors() {
    if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
        C_RESET="$(tput sgr0   2>/dev/null || printf '')"; C_GREEN="$(tput setaf 2 2>/dev/null || printf '')"
        C_YELLOW="$(tput setaf 3 2>/dev/null || printf '')"; C_RED="$(tput setaf 1 2>/dev/null || printf '')"
        C_CYAN="$(tput setaf 6  2>/dev/null || printf '')"; C_BOLD="$(tput bold   2>/dev/null || printf '')"
    else
        C_RESET=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''; C_BOLD=''
    fi
}
_init_colors

info()    { printf '%b[INFO]  %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
warn()    { printf '%b[WARN]  %s%b\n' "$C_YELLOW" "$*" "$C_RESET"; }
fatal()   { printf '%b[FATAL] %s%b\n' "$C_RED"    "$*" "$C_RESET" >&2; exit 1; }
ok()      { printf '%b[OK]    %s%b\n' "$C_GREEN"  "$*" "$C_RESET"; }
log()     { [ "$VERBOSE" -ne 0 ] && printf '[DEBUG] %s\n' "$*" || true; }
section() { printf '\n%b=== %s ===%b\n' "${C_BOLD}${C_CYAN}" "$*" "$C_RESET"; }

usage() {
    printf 'Usage: %s [OPTIONS]\n\n' "$PROGNAME"
    printf 'Simple CSV import into MySQL from /tmp/csv-import/ without a credentials file.\n\n'
    printf 'Options:\n'
    printf '  -v, --verbose    Enable verbose/debug output\n'
    printf '      --version    Print version and exit\n'
    printf '  -h, --help       Show this help message\n'
}

_run() {
    if [ -n "$SUDO_CMD" ]; then "$SUDO_CMD" "$@"; else "$@"; fi
}

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose)  VERBOSE=1 ;;
            --version)     printf '%s version %s\n' "$PROGNAME" "$VERSION"; exit 0 ;;
            -h|--help)     usage; exit 0 ;;
            *)             fatal "Unknown option: $1" ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"

    if [ "$(id -u)" -ne 0 ]; then
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || warn "sudo not found."
    fi

    CURRENT_DATE=$(date "+%Y%m%d%H%M%S")
    log "Started at ${CURRENT_DATE}"

    # define database connectivity
    _db="tmp"
    _db_user="root"
    _db_password="toor"

    # define directory containing CSV files
    # _csv_directory="/var/lib/mysql-files/"
    _csv_directory="/tmp/csv-import/"

    # go into directory
    cd "$_csv_directory"

    # get a list of CSV files in directory
    _csv_files=$(ls -1 *.csv)

    section "Starting simple CSV import"

    # loop through csv files
    for _csv_file in ${_csv_files[@]}; do

        # remove file extension
        _csv_file_extensionless=$(printf '%s' "$_csv_file" | sed 's/\(.*\)\..*/\1/')

        # define table name
        _table_name="${_csv_file_extensionless}"

        # get header columns from CSV file
        _header_columns=$(head -1 "${_csv_directory}/${_csv_file}" | tr ',' '\n' | sed 's/^"//' | sed 's/"$//' | sed 's/ /_/g')
        _header_columns_string=$(head -1 "${_csv_directory}/${_csv_file}" | sed 's/ /_/g' | sed 's/"//g')

        # ensure table exists
        mysql -u "$_db_user" -p"$_db_password" "$_db" <<eof
  	 DROP TABLE IF EXISTS \`$_table_name\`;
	-- TRUNCATE TABLE \`$_table_name\`;
    CREATE TABLE IF NOT EXISTS \`$_table_name\` (
      id int(11) NOT NULL auto_increment,
      PRIMARY KEY  (id)
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1
eof

        # loop through header columns
        for _header in ${_header_columns[@]}; do

            # add column
            mysql -u "$_db_user" -p"$_db_password" "$_db" --execute="alter table \`${_table_name}\` add column \`${_header}\` text"

        done

        # import csv into mysql
        mysqlimport --ignore-lines=1 --fields-enclosed-by='"' --fields-terminated-by=',' --lines-terminated-by="\n" \
            --columns="$_header_columns_string" -u "$_db_user" -p"$_db_password" "$_db" "${_csv_directory}/${_csv_file}"

    done

    ok "Simple CSV import complete."
}
main "$@"
