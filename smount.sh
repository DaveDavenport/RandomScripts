#!/bin/bash
# This script is written by Qball Cow <qball@gmpclient.org>
# This script is public domain, you are free todo whatever you like with it.
#
# Config file ~/.smount.conf
# stucture:
# <name>=<ssh host>:<path>
# <name2>=<ssh host2>:<path>
#
# Autocomplete function:
#
#_smount.sh()
#{
# COMPREPLY=()
# curw=${COMP_WORDS[COMP_CWORD]}
# COMPREPLY=($(compgen -W '$(smount.sh -l)' -- $curw))
#}
#complete -F _smount.sh smount.sh
#

BASH=bash
CONF_FILE=~/.smount.conf
DIRECTORY=~/.remote/


function clearlock()
{
    NAME="${1}"
    RPATH="${DIRECTORY}/${NAME}"
    if [ -f "${RPATH}.count" ];
    then
        rm "${RPATH}.count";
    fi
}

# create a numbered lock.
# return 0 when lock is newly created.
# returns 1 when lock existed (it increments the lock count)
function lock()
{
    NAME="${1}"
    RPATH="${DIRECTORY}/${NAME}"
    lockfile-create "${RPATH}"
    if [ -f "${RPATH}.count" ];
    then
        echo $(($(cat "${RPATH}.count")+1)) > "${RPATH}.count"
        lockfile-remove "${RPATH}"
        return 1
    else
        echo 1 >  "${RPATH}.count"
        lockfile-remove "${RPATH}"
        return 0
    fi
}

# unlock a numbered lock.
# returns 0 if last lock is gone.
# returns 1 if something still holds a lock.
function unlock()
{
    NAME="${1}"
    RPATH="${DIRECTORY}/${NAME}"

    lockfile-create "${RPATH}"
    if [ -f "${RPATH}.count" ];
    then
        echo $(($(cat "${RPATH}.count")-1)) > "${RPATH}.count"
        if [ $(cat "${RPATH}.count") = 0 ]
        then
            # remove count file.
            rm "${RPATH}.count"
            # remove lock
            lockfile-remove "${RPATH}"
            return 0
        else
            # remove lock
            lockfile-remove "${RPATH}"
            return 1
        fi
    else
        # No count file? then assume no lock.
        lockfile-remove "${RPATH}"
        return 0
    fi
}


##
# mount it, and go in.
##
function smount()
{
    # SSH mount name.
    NAME="${1}"


    eval SSH_mount=\$${1}
    if [ -z "${SSH_mount}" ]
    then
        echo "Profile \"${NAME}\" does not exists";
        exit 0;
    fi

    # Remote path
    RPATH="${DIRECTORY}/${NAME}"

    if [ ! -d "${RPATH}" ]
    then
        mkdir "${RPATH}";
    fi

    # Mount
    if lock "${NAME}"
    then
        echo "Mounting: ${NAME}"
        sshfs "${SSH_mount}" "${RPATH}"

        # Check if mount worked.
        if [ "$?" != "0" ]
        then
            echo "Failed to mount: ${SSH_mount}";
            # Undo set lock
            unlock "${NAME}"
            exit 0;
        fi
    else
       if $(mount | awk -v val="${SSH_mount}" '($1 == val) {exit 1}')
       then
            echo "Failed to lock, stall lock file"
            clearlock "${NAME}"
            smount "${NAME}"
            exit 0;
       fi
    fi

    # set profile
    export SP_PROFILE="SSH:${NAME}"
    pushd "${RPATH}" 2&>/dev/null

    # Enter interactive subshell
    ${BASH}
    popd 2&>/dev/null

    # Unmount it again.
    if unlock "${NAME}"
    then
        echo "Unmounting"
        fusermount -uz "${RPATH}"
    fi
}


list_profiles()
{
  # should be able todo this in one command.
  egrep -E "^(.*)=.*$" ${CONF_FILE} | awk -F'=' '{print $1}'
}

function check()
{
    if [ -z "$1" ]; then
        echo "Usage: smount.sh <path>";
        exit 0;
    fi

    if [ ! -d "${DIRECTORY}" ]; then
        mkdir "${DIRECTORY}";
    fi

    if [ ! -z "${SP_PROFILE}" ]
    then
        echo "Already inside a mount/profile";
        exit;
    fi

}
##
# option parser
##
while getopts hlvrd:s: OPT; do
    case "$OPT" in
        l)
            list_profiles
      exit 0
            ;;
    esac
done
# Remove the switches we parsed above.
shift `expr $OPTIND - 1`



check $@
source "${CONF_FILE}"
smount $@
