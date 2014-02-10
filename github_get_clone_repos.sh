#!/bin/bash

USER=DaveDavenport
HOST=github


REPOS=$(
    curl https://api.github.com/users/${USER}/repos | 
    grep "full_name"  |
    sed 's/[ \t]*\"\(.*\)\": \"\(.*\)",/\2/g' 
)


for REPO in ${REPOS}
do
    echo "=== Updating repo: ${REPO}"
    REPO_DIR=$(basename ${REPO})

    if [ -d ${REPO_DIR} ]
    then
        pushd ${REPO_DIR}
            git pull
        popd
    else
        git clone ${HOST}:${REPO}
    fi

done
