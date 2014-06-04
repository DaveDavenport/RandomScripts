#!/usr/bin/env bash

BPATH="/sys/devices/platform/s3c24xx-pwm.0/pwm-backlight.0/backlight/pwm-backlight.0"

MINB=0
MAXB=$(cat ${BPATH}/max_brightness)

CUR=$(cat ${BPATH}/brightness)

C_STATE=$(((${CUR}*100)/${MAXB}))

function list_brightness()
{
    for val in 5 10 15 30 50 70 100 
    do
        if [ ${val} -eq ${C_STATE} ]
        then
            echo "*${val} %" 
        else
            echo "${val} %" 
        fi
    done
}

VAL=$(list_brightness | rofi -dmenu -p "brightness:")

if [ -n "${VAL}" ]
then
    NEW_STATE=$((${VAL% *}*${MAXB}/100))
    echo ${NEW_STATE} > ${BPATH}/brightness
fi


