#!/usr/bin/env bash

set -o errexit
set -o nounset

# This script will print GitHub errors when files from subtrees have been edited.
# Those files should be edited in their respective repositories.

MASTER_REVISION=$(git rev-list --first-parent origin/master | head -n 1)
DIFFED_FILES=$(git diff --name-only "$MASTER_REVISION")

FAILED=false

if echo "$DIFFED_FILES" | grep -qP "^gamemode/modules/fpp/pp/"; then
    echo "::error::Files from Falco's Prop Protection have been edited. Please submit a PR to https://github.com/fptje/falcos-Prop-protection instead!"
    FAILED=true
fi

if echo "$DIFFED_FILES" | grep -qP "^gamemode/libraries/fn.lua"; then
    echo "::error::The fn library has been edited. Please submit a PR to https://github.com/fptje/GModFunctional instead!"
    FAILED=true
fi

if echo "$DIFFED_FILES" | grep -qP "^gamemode/libraries/mysqlite/mysqlite.lua"; then
    echo "::error::The MySQLite library has been edited. Please submit a PR to https://github.com/fptje/MySQLite instead!"
    FAILED=true
fi

if echo "$DIFFED_FILES" | grep -qP "^gamemode/libraries/simplerr.lua"; then
    echo "::error::The Simplerr library has been edited. Please submit a PR to https://github.com/fptje/simplerr instead!"
    FAILED=true
fi

if echo "$DIFFED_FILES" | grep -qP "^gamemode/libraries/sh_cami.lua"; then
    echo "::error::The CAMI library has been edited. Please submit a PR to https://github.com/glua/CAMI instead!"
    FAILED=true
fi

if echo "$DIFFED_FILES" | grep -qP "^gamemode/modules/fspectate/"; then
    echo "::error::Files from FSpectate have been edited. Please submit a PR to https://github.com/fptje/FSpectate instead!"
    FAILED=true
fi

if [[ "$FAILED" = true ]]; then
    exit 1
fi
