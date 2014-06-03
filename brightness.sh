#!/usr/bin/env bash

BPATH="/sys/devices/platform/s3c24xx-pwm.0/pwm-backlight.0/backlight/pwm-backlight.0"

MINB=0
MAXB=$(cat /sys/devices/platform/s3c24xx-pwm.0/pwm-backlight.0/backlight/pwm-backlight.0/max_brightness)


function list_brightness()
{
    for val in `seq 10 15 100`
    do
        echo "${val} %" 
    done
}

VAL=$(list_brightness | rofi -dmenu -p "brightness:")

if [ -n "${VAL}" ]
then
    echo ${VAL% *}
    NEW_STATE=$((${VAL% *}*${MAXB}/100))
    echo ${NEW_STATE} > ${BPATH}/brightness
fi


