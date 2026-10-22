#!/usr/bin/env bash
# -----------------------------------------------------------------------------------
# A starting point for a new script: copy it, rename it, and replace its last section
# with what your script does. On its own it only prints the environment that Smarter
# gives a script, and changes nothing. It isn't listed in scripts.yaml, so Smarter
# never runs it.
#
# Smarter runs a script that scripts.yaml lists in the repository's root folder, with
# the args of its entry, and with only these environment variables:
#
#   SMARTER_REPOSITORY_URL           this repository's url
#   SMARTER_REPOSITORY_ROOT          the folder it was cloned into, the script's working folder
#   SMARTER_ACCOUNT_NUMBER           the account that owns the repository's resources
#   SMARTER_USERNAME                 the user that owns them
#   SMARTER_DATABASE_HOST            the host of the platform's database server
#   SMARTER_DATABASE_PORT            its port
#   SMARTER_DATABASE_ADMIN_USERNAME  its administrator
#   MYSQL_PWD                        the administrator's password, where the MariaDB and
#                                    MySQL clients read it (missing if the platform has none)
#
# plus PATH, HOME, LANG, LC_ALL and TZ, if the platform has them. Smarter logs each line
# that a script writes: stdout as its report, and stderr as problems. A script fails by
# exiting non-zero, or by running out of time.
#
# Usage:
#   scripts/getting-started.sh         # print the environment that Smarter gives a script
#   scripts/getting-started.sh --help  # show this help
#
# Options:
#   -h, --help   show this help
# -----------------------------------------------------------------------------------
set -eu

usage() {
    sed -n '/^# Usage:/,/^# ---/p' "$0" | sed -e '$d' -e 's/^# \{0,1\}//'
}

# The report, on stdout. Each line stands on its own, because Smarter logs it as one line, after the
# script's name.
report() {
    printf '%s\n' "$*"
}

# Stop, with the reason on stderr, and exit status 1.
fail() {
    printf 'FAILED: %s\n' "$*" >&2
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help) usage; exit 0 ;;
        *) usage >&2; fail "unknown option: $1" ;;
    esac
done

# -----------------------------------------------------------------------------------
# Replace this section with what your script does.
# -----------------------------------------------------------------------------------
report "working folder: $(pwd)"
report "SMARTER_REPOSITORY_URL=${SMARTER_REPOSITORY_URL:-(not set)}"
report "SMARTER_REPOSITORY_ROOT=${SMARTER_REPOSITORY_ROOT:-(not set)}"
report "SMARTER_ACCOUNT_NUMBER=${SMARTER_ACCOUNT_NUMBER:-(not set)}"
report "SMARTER_USERNAME=${SMARTER_USERNAME:-(not set)}"
report "SMARTER_DATABASE_HOST=${SMARTER_DATABASE_HOST:-(not set)}"
report "SMARTER_DATABASE_PORT=${SMARTER_DATABASE_PORT:-(not set)}"
report "SMARTER_DATABASE_ADMIN_USERNAME=${SMARTER_DATABASE_ADMIN_USERNAME:-(not set)}"
# Never print a password: report only whether it is set.
if [ -n "${MYSQL_PWD:-}" ]; then
    report "MYSQL_PWD is set"
else
    report "MYSQL_PWD is not set"
fi
