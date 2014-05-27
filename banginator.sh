#!/usr/bin/env bash

EMAIL="thunderbird -compose \"to=\${email}\""
WEB="firefox \${url}"



function prompt() {
    printf "%s\n" "$@" | rofi -dmenu -p "Bang:"
}



function load_url()
{
    echo "Load url: $1"
    url="$1"
    eval "${WEB}"
}

function email()
{
    echo "E-mail: $1"
    email="$1"
    eval "${EMAIL}"
}

function start()
{
    menu=(
        "!.  Web"
        "@.  E-mail"
    )

    prompt "${menu[@]}"

}

value="$(start)"
echo "${value}"
case "${value}" in

    !*)
        load_url "${value#!}";;
    @*)
        email "${value#@}";;
esac
