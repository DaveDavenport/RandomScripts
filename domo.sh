# ! /usr/bin/env bash 

LIGHT_HOST=192.150.0.112
LIGHT_PORT=8888

prompt() {
    printf "%s\n" "$@" | rofi -dmenu -p "Domotica:"
}

function get_range_value()
{
    menu=(
        "0.   Lights 0%"
        "10.  Lights 10%"
        "20.  Lights 20%"
        "30.  Lights 30%"
        "40.  Lights 40%"
        "50.  Lights 50%"
        "60.  Lights 60%"
        "70.  Lights 70%"
        "80.  Lights 80%"
        "90.  Lights 90%"
        "100. Lights 100%"
    )
    prompt "${menu[@]}"
}

function set_lights()
{
    case "$(get_range_value)" in
        0.*) echo "0" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: off."
            ;;
        10.*) echo "2" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 10%."
            ;;
        20.*) echo "4" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 20%."
            ;;
        30.*) echo "8" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 30%."
            ;;
        40.*) echo "16" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 40%."
            ;;
        50.*) echo "32" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 50%."
            ;;
        60.*) echo "64" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 60%."
            ;;
        70.*) echo "128" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 70%."
            ;;
        80.*) echo "256" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 90%."
            ;;
        90.*) echo "512" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 90%."
            ;;
        100.*) echo "1024" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 100%."
            ;;
    esac
}
function set_maximum()
{
    case "$(get_range_value)" in
        0.*) echo "setmax 0" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        10.*) echo "setmax 2" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        20.*) echo "setmax 4" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        30.*) echo "setmax 8" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        40.*) echo "setmax 16" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        50.*) echo "setmax 32" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        60.*) echo "setmax 64" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        70.*) echo "setmax 128" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        80.*) echo "setmax 256" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        90.*) echo "setmax 512" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        100.*) echo "setmax 1024" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
    esac
}
function set_minimum()
{
    case "$(get_range_value)" in
        0.*) echo "setmin 0" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        10.*) echo "setmin 2" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        20.*) echo "setmin 4" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        30.*) echo "setmin 8" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        40.*) echo "setmin 16" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        50.*) echo "setmin 32" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        60.*) echo "setmin 64" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        70.*) echo "setmin 128" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        80.*) echo "setmin 256" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        90.*) echo "setmin 512" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
        100.*) echo "setmin 1024" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};;
    esac
}


function get_maximum()
{
    sleep 0.05
    echo "getmax" | nc 192.150.0.109 8888
}

function get_minimum()
{
    sleep 0.05
    echo "getmin" | nc 192.150.0.109 8888
}
function configure()
{
    menu=(
        "Auto lights mode setup"
        "1.  Set minimum value."
        "2.  Set maximum value."
        ""
        "Current minimum: $(get_minimum)"
        "Current maximum: $(get_maximum)"
    )


    case "$(prompt "${menu[@]}")" in
        1.*) set_minimum;;
        2.*) set_maximum;;
    esac
}

function menu()
{
    menu=(
        "Lights on/off"
        ""
        "10.  Lights Low"
        "60.  Lights Middle"
        "100. Lights Full"
        "%.   Lights (advanced)"
        ""
        "Configure"
    )

    case "$(prompt "${menu[@]}")" in
        "Lights on/off") echo "toggle"  "switch" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
        notify-send "Domotica" "Toggle light."
            ;;
        10.*) echo "2" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 10%."
            ;;
        20.*) echo "4" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 20%."
            ;;
        30.*) echo "8" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 30%."
            ;;
        40.*) echo "16" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 40%."
            ;;
        50.*) echo "32" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 50%."
            ;;
        60.*) echo "64" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 60%."
            ;;
        70.*) echo "128" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 70%."
            ;;
        80.*) echo "256" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 80%."
            ;;
        90.*) echo "512" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 90%."
            ;;
        100.*) echo "1024" | nc -q0 ${LIGHT_HOST} ${LIGHT_PORT};
            notify-send "Domotica" "Set light level: 100%."
            ;;
        \%.*) set_lights;;
        Configure)
                configure
            ;;
    esac
}

menu
