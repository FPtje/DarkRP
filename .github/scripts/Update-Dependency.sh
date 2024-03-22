#!/usr/bin/env bash

#
#   Exports an update function that copies
#   a dependency from a remote repository.
#


function print {
    local text="$1"
    echo ">>> ${text}"
}

function alert {
    local text="$1"
    echo -e "\e[31m[!] ${text}\e[0m"
}

function cyan {
    local text="$1"
    echo -e "\e[36m${text}\e[0m"
}


function hasRemote {

    local remote="$1"

    git remote |
    grep --silent "^$remote$"

    return $?
}

function hasChanges {

    git status --porcelain 'gamemode' |
    grep --silent '.'

    return $?
}

function toFolder (

    local path="$1"

    local last="$( basename "$path" )"

    if [[ "$last" == *.* ]] ; then
        path="$( dirname "$path" )"
    fi

    echo "$path"
)


function update {

    local Usage="Use update 'Remote Name' 'Repository Url' 'Target Folder' ( 'Source Folder' )"


    local dry="$1"

    if [ "$dry" == 'dry=true' ] ; then
        dry=true
    else
        dry=false
    fi


    local remote="$2"

    if [ -z "$remote" ] ; then
        alert "The <Remote Name> parameter is missing"
        print "$Usage"
        return 1
    fi


    local repository="$3"

    if [ -z "$repository" ] ; then
        alert "The <Repository Url> parameter is missing"
        print "$Usage"
        return 1
    fi


    local target="$4"

    if [ -z "$target" ] ; then
        alert "The <Target Folder> parameter is missing"
        print "$Usage"
        return 1
    fi


    local source="$5"


    echo ""
    print "[ Updating $( cyan "$remote" ) ]( Dry : ${dry} )"


    if hasRemote "$remote" ; then

        print "Updating remote repository url."

        git remote set-url "$remote" "$repository"

        if (( $? != 0 )) ; then
            alert "Failed to update remote repository"
            return 1
        fi

    else

        print "Adding remote repository url."

        git remote add "$remote" "$repository"

        if (( $? != 0 )) ; then
            alert "Failed to add remote repository"
            return 1
        fi
    fi


    print "Fetching remote repository"

    git fetch "$remote"

    if (( $? != 0 )) ; then
        alert "Failed to fetch remote repository"
        return 1
    fi


    print "Removing local target folder"

    git rm -r --force "$target"

    if (( $? != 0 )) ; then
        alert "Failed to remove local target folder"
        return 1
    fi


    print "Reading data from remote"

    local location="${remote}/master"

    if [ -n "$source" ] ; then
        location="${location}:${source}"
    fi


    local prefix="$( toFolder "$target" )"

    git read-tree           \
        --prefix="$prefix"  \
        -u                  \
        "$location"

    if (( $? != 0 )) ; then
        alert "Failed to read data from remote"
        return 1
    fi


    if hasChanges ; then

        print "Committing dependency changes"

        if [ "$dry" == 'false' ] ; then

            git add 'gamemode'

            git commit \
                -m "Dependency Update - ${remote}"

        fi

        print "Committed changes"

        return 0

    else
        print "The dependency is already up-to-date."
        return 0
    fi
}


export -f update
