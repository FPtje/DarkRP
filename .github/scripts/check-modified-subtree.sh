#!/usr/bin/env bash

#
# Prints a list of errors for any dependencies that have been edited.
# Dependencies should be edited in their respective repositories
#

echo 'Checking for any dependency changes.'

set -o errexit # Exit for any error
set -o nounset # Error when referencing unset vars


commit=$(
    git rev-list                        \
        --first-parent origin/master    \
        --max-count=1
)

files=$(
    git diff        \
        --name-only \
        "$commit"
)


# Template for the GitHub summary

template="
    > [!WARNING]
    > Files from **[{project}]({repository})** have been modified!
    > These changes originally come from [{project}]({repository}), but are synchronized to DarkRP.
    > These files should be edited in the original repositories instead.
    >
    {files}
    >
"

# Trim leading space for Markdown compatibility

template="$( echo "$template" | sed 's/^[[:space:]]*//' )"


failed=false

function check {

    local name="$1"
    local path="^$2"
    local repo="$3"


    # Check if any matching files were modified
    local matched=$(
        echo "$files" |
        grep --perl-regexp "$path"
    )


    # Ignore if nothing matched
    if [ -z "$matched" ] ; then
        return
    fi


    # Append info to GitHub's summary
    local info="$template"

    matched="$(printf -- '> `%s`  \n' "$matched")"

    info=${info//\{repository\}/$repo}
    info=${info//\{project\}/$name}
    info=${info//\{files\}/$matched}

    echo "$info" >> "$GITHUB_STEP_SUMMARY"

    failed=true
}


check   "Falco's Prop Protection"   \
        'gamemode/modules/fpp/pp/'  \
        'https://github.com/fptje/falcos-Prop-protection'


check   "FN Library"                \
        'gamemode/libraries/fn.lua' \
        'https://github.com/fptje/GModFunctional'


check   "MySQLite Library"                          \
        'gamemode/libraries/mysqlite/mysqlite.lua'  \
        'https://github.com/fptje/MySQLite'


check   "Simplerr Library"                  \
        'gamemode/libraries/simplerr.lua'   \
        'https://github.com/fptje/simplerr'


check   "CAMI Library"                      \
        'gamemode/libraries/sh_cami.lua'    \
        'https://github.com/glua/CAMI'


check   "FSpectate"                     \
        'gamemode/modules/fspectate/'   \
        'https://github.com/fptje/FSpectate'


if [[ "$failed" = true ]] ; then
    echo 'Some dependencies have been modified!'
    exit 1
fi


echo 'No dependencies have been modified.'

exit 0
