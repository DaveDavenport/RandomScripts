#!/bin/bash

MAX_DESKTOPS=20

WORKSPACES=$(seq -s '\n' 1 1 ${MAX_DESKTOPS})

EMPTY_WORKSPACE=$( (i3-msg -t get_workspaces | jq .[].num ; \
            echo -e ${WORKSPACES} ) | sort -n | uniq -u | head -n 1)

i3-msg workspace ${EMPTY_WORKSPACE}
