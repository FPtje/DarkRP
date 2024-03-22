#!/usr/bin/env bash

#
#   Update a dependency from a remote repository.
#

echo '>>> Updating dependencies.'

set -o errexit # Exit for any error

dry=false


source "$( dirname "$0" )/Update-Dependency.sh"


update  "dry=${dry}"                          \
        'MySQLite'                            \
        'https://github.com/FPtje/MySQLite'   \
        'gamemode/libraries/mysqlite/'

update  "dry=${dry}"                                        \
        'PropProtection'                                    \
        'https://github.com/fptje/falcos-Prop-protection'   \
        'gamemode/modules/fpp/pp/'                          \
        'lua/fpp'

update  "dry=${dry}"                                \
        'GModFunctional'                            \
        'https://github.com/fptje/GModFunctional'   \
        'gamemode/libraries/fn.lua'

update  "dry=${dry}"                        \
        'Simplerr'                          \
        'https://github.com/fptje/simplerr' \
        'gamemode/libraries/simplerr.lua'

update  "dry=${dry}"                        \
        'CAMI'                              \
        'https://github.com/glua/CAMI'      \
        'gamemode/libraries/sh_cami.lua'    \
        'lua/autorun'

update  "dry=${dry}"                            \
        'Spectate'                              \
        'https://github.com/fptje/FSpectate'    \
        'gamemode/modules/fspectate/'           \
        'lua/fspectate'


function noCommits {

    local current=$(
        git rev-parse HEAD
    )

    local branch=$(
        git rev-parse \
            --abbrev-ref HEAD
    )

    local origin=$(
        git rev-parse \
            "origin/${branch}"
    )

    if [ "$current" == "$origin" ] ; then
        return 0
    else
        return 1
    fi
}


if noCommits ; then

    echo ">>> All dependencies are already up-to-date."

    echo ">>> Finished"

    exit 0

fi


echo ">>> Pushing commits to repository."

if [ "$dry" == 'false' ] ; then
    git push origin
fi

echo ">>> Finished"

