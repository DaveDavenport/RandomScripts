#!/usr/bin/env bash

declare -A TITLES
declare -A COMMANDS

###
# List of defined 'bangs'
###

COMMANDS['!tb']="thunderbird -compose \"to=\${input}\""
TITLES['!tb']="e-mail"

COMMANDS["!ff"]="firefox \"\${input}\""
TITLES["!ff"]="Web browser"

COMMANDS["!g"]="firefox --search \"\${input}\""
TITLES["!g"]="Web search"

COMMANDS["!gi"]="firefox --search \"!gi \${input}\""
TITLES["!gi"]="Image search"
###
# do not edit below
###

##
# Generate menu
##
function print_menu()
{
    for key in ${!TITLES[@]}
    do
        echo "$key    ${TITLES[$key]}"
    done
}
##
# Show rofi.
##
function start()
{
    print_menu | rofi -dmenu -p "Bang:" 
}


# Run it
value="$(start)"

# Split input.
# grab upto first space.
choice=${value%%\ *}
# graph remainder, minus space.
input=${value:$((${#choice}+1))}

##
# Cancelled? bail out
##
if test -z ${choice}
then
    exit
fi

# check if choice exists
if test ${COMMANDS[$choice]+isset}
then
    # Execute the choice
    eval echo "Executing: ${COMMANDS[$choice]}"
    eval ${COMMANDS[$choice]}
else
    echo "Unknown command: ${choice}" | rofi -dmenu -p "error"
fi
