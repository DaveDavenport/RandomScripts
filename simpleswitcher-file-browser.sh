#!/bin/bash

EDITOR=gvim


function list_directory()
{
    echo ".."
    ls
}

declare -i quit=0;
while [ $quit != 1 ];
do
    SELECTED=$(list_directory | simpleswitcher -dmenu -p ${PWD} )

    # Check if directory
    if [ -d "${SELECTED}" ]
    then
        pushd "${SELECTED}"
    elif [ x"${SELECTED}" = x".."  ]
    then
        popd
    elif [ -x "${SELECTED}" ]
    then
        ./"${SELECTED}"
        quit=1;
    elif [ -f "${SELECTED}" ]
    then
        ${EDITOR} "${SELECTED}"
        quit=1;
    elif [ -z "${SELECTED}" ] || [  x"${SELECTED}" = x"quit" ]
    then
        quit=1;
    fi
done
