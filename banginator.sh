#!/usr/bin/env bash

declare -A TITLES
declare -A COMMANDS

###
# List of defined 'bangs'
###

COMMANDS['@']="thunderbird -compose \"to=\${input}\""
TITLES['@']="e-mail"

COMMANDS["!"]="firefox \"\${input}\""
TITLES["!"]="Web browser"

COMMANDS["/"]="firefox --search \"\${input}\""
TITLES["/"]="Web search"

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
    print_menu | rofi -dmenu -prompt "Bang:" 
}


# Run it
value="$(start)"

# Split input.
choice=${value:0:1}
input=${value:1}

# check if choice exists
if test ${COMMANDS[$choice]+isset}
then
    # Execute the choice
    eval echo "Executing: ${COMMANDS[$choice]}"
    eval ${COMMANDS[$choice]}
else
    echo "Unknown command: ${choice}" | rofi -dmenu -p "error"
fi
