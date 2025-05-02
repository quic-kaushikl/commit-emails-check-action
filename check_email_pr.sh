#!/usr/bin/env bash
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause

debug() { echo "::debug::$1" >&2 ; } # message
error() { echo "::error::$1" >&2 ; } # message

# https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#list-commits-on-a-pull-request
get_pr_commits() {
    [ -n "$TEST_MODE" ] && cat ./test/pr_list_commits.json && return
    [ "$COMMITS_COUNT" -gt 100 ] && debug "Needs pagination"
    # TODO: Handle paginated results
    # https://docs.github.com/en/rest/using-the-rest-api/using-pagination-in-the-rest-api?apiVersion=2022-11-28#using-link-headers
    curl -L --no-progress-meter \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/repos/$GITHUB_REPOSITORY_OWNER/$GITHUB_REPOSITORY/pulls/$PULL_NUMBER/commits?per_page=$COMMITS_COUNT"
}

split_commits_and_add_metadata() {
    jq -c '.[] |= . + {"extra_allowed_emails": [], "license_type": "OPEN_SOURCE"} | .[]'
}

usage() { # error_message [error_code]
    local prog=$(basename -- "$0")
    cat <<EOF

    usage: $prog [--test]

EOF
    [ $# -gt 0 ] && error "$@"
    [ $# -gt 1 ] && exit $2
    exit 10
}

while [ $# -gt 0 ] ; do
    case "$1" in
        --test) shift ; TEST_MODE=("--verbose") ;;
        *) usage ;;
    esac
    shift
done

RESULT=0
while read -r pr_commit ; do
    debug "Running check on: $pr_commit"
    ./src/check_email.sh --json "$pr_commit" "${TEST_MODE[@]}" || RESULT=1
done < <(get_pr_commits | split_commits_and_add_metadata)

exit $RESULT
