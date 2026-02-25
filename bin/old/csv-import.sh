#!/usr/bin/env bash
# ==============================================================================
# csv-import.sh — import CSV files into MySQL using a credentials file
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

# -- SET GLOBAL slow_query_log = 'ON'; select @@slow_query_log Performance
# Tip(1) :- More over you can define table definition into Mysql after first
# import select * from tableName procedure analyse()
#
# Performance Tip(2) :- open CSV with excel and do column wise =
# max(len(RANGE:RANGE)) and assign value to data type in mysql
#
# I personaly like (2) approach to complete this kind of job with +5 increment
# of data length for feature.

usage() {
    printf 'Usage: %s [OPTIONS]\n\n' "$PROGNAME"
    printf 'Import CSV files from /var/lib/mysql-files into MySQL using a credentials file.\n\n'
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
        command -v sudo >/dev/null 2>&1 && SUDO_CMD="sudo" || fatal "This script only works with [root] user or sudo."
    fi

    # define database connectivity
    _db="tmp"
    _db_user="root"
    _db_password="toor"
    _db_host="localhost"
    _db_port="3306"

    # mysql_config_editor set --login-path=local --host=localhost --user=username
    # --password

    # To avoide :- [Warning] Using a password on the command line interface can be
    # insecure.
    # Usage for mysqldump --defaults-extra-file=$credentialsFile .....
    # Usage for mysql --defaults-extra-file=$credentialsFile .....
    credentialsFile="/tmp/mysql-credentials.cnf"

    section "CSV Import @started"
    printf '[client]\n'           > "$credentialsFile"
    printf 'user=%s\n'  "$_db_user"     >> "$credentialsFile"
    printf 'password=%s\n' "$_db_password" >> "$credentialsFile"
    printf 'host=%s\n' "$_db_host"     >> "$credentialsFile"

    # define directory containing CSV files
    _csv_directory="/var/lib/mysql-files"

    if [ ! -d "${_csv_directory}" ]; then
        info "Creating CSV directory"
        mkdir -p "${_csv_directory}"
    fi

    # go into directory
    cd "$_csv_directory"

    # get a list of CSV files in directory
    _csv_files=$(ls -1 *.csv)

    # loop through csv files
    for _csv_file in ${_csv_files[@]}; do

        #Replace header line symbol from | to ,
        sed -i "1s/|/,/g" "$_csv_file"

        # remove file extension
        _csv_file_extensionless=$(printf '%s' "$_csv_file" | sed 's/\(.*\)\..*/\1/')

        # define table name
        _table_name="${_csv_file_extensionless}"

        # get header columns from CSV file
        _header_columns=$(head -1 "${_csv_directory}/${_csv_file}" | tr ',' '\n' | sed 's/^"//' | sed 's/"$//' | sed 's/ /_/g')
        _header_columns_string=$(head -1 "${_csv_directory}/${_csv_file}" | sed 's/ /_/g' | sed 's/"//g')

        # Ensure table exists
        mysql --defaults-extra-file="$credentialsFile" "$_db" <<eof
	 DROP TABLE IF EXISTS \`$_table_name\`;
	-- TRUNCATE TABLE \`$_table_name\`;
	CREATE TABLE IF NOT EXISTS \`$_table_name\` (
	  id int(11) NOT NULL auto_increment,
	  PRIMARY KEY  (id)
	) ENGINE=MyISAM DEFAULT CHARSET=latin1;
eof

        # loop through header columns
        for _header in ${_header_columns[@]}; do
            # add column
            mysql --defaults-extra-file="$credentialsFile" "$_db" \
                --execute="alter table \`${_table_name}\` add column ${_header} text"
        done

        # import csv into mysql and change parameter as per CSV format.
        # --fields-enclosed-by='"' \
        mysqlimport \
            --ignore-lines=1 \
            --fields-terminated-by='|' \
            --lines-terminated-by="\n" \
            --columns="$_header_columns_string" \
            -u "$_db_user" \
            -p"$_db_password" \
            "$_db" "${_csv_directory}/${_csv_file}"
        # > /dev/null 2>&1

    done

    rm "$credentialsFile"
    section "CSV Import @end"
    ok "CSV import complete."
}
main "$@"
