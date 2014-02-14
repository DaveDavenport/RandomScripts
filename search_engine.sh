#!/bin/bash

QUERY=$(echo -n | simpleswitcher -dmenu -p "Search:" -loc 0 -o 80 -font "Source Code Pro-10" -padding 3 -bg "#333" -fg "#1aa" -hlfg "#111" -hlbg "#1aa" -bc "#277" )

if [ -n "${QUERY}" ]
then
    firefox -search "$QUERY"
fi
