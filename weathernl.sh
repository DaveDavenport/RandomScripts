#!/usr/bin/env bash

LATITUDE=52.06
LONGITUDE=5.11

NOW=$(date +%s)
declare -A WEATHER;
function dl()
{
    curl "http://gps.buienradar.nl/getrr.php?lat=${LATITUDE}&lon=${LONGITUDE}" 2>/dev/null | tr -d '\r'
}

RAINING=false
STOP=0
START=0

function get_prediction()
{
    while read A
    do
        SM=(${A//\|/ })
        
        STIME=$(date +%s -d ${SM[1]})
        DTIME=$(( ($STIME-$NOW)/60 ))
        if [ ${DTIME} -le 0 ] && [ ${DTIME} -gt -5 ]
        then
            if [ ${SM[0]} -gt 0 ]
            then
                RAINING=true
            fi
        fi

        if [ ${DTIME} -gt 0 ]
        then
            if ${RAINING} && [ ${SM[0]} -eq 0 ] && [ ${STOP} -eq 0 ]
            then
                STOP=${DTIME}
            fi
            if ! ${RAINING} && [ ${SM[0]} -gt 0 ] && [ ${START} -eq 0 ]
            then
                START=${DTIME}
            fi
        fi
    done <  <(dl) 

}

get_prediction

if ${RAINING}
then
    echo "It is raining"
    if [ ${STOP} -gt 0 ]
    then
        echo "It will stop in ${STOP} minutes."
    else
        echo "It won't stop for the next 2 hours."
    fi
else
    echo "It is not raining"
    if [ ${STOP} -gt 0 ]
    then
        echo "It will start in ${STOP} minutes."
    else
        echo "It won't start for the next 2 hours."
    fi
fi
