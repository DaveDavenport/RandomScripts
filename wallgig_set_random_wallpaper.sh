#!/bin/bash

##
# wallgig_set_random_wallpaper.sh
# Written by: qball _at_ gmpclient _dot_ org
# 
# Script fetches a random wallpaper from wallgig.net and sets this as background.
# Preferences on what to display and what not to display can be specified.
#
# This script is public domain, you are free todo whatever you like with it.
# The tools by this script are not!
#
# Script uses the following external tools:
# Curl: To fetch data from the interwebs
#       Install: See package manager.
# MultiMonitorBackground: Set background wallpaper (multi monitor aware)
#       Install: https://github.com/DaveDavenport/MultiMonitorBackground
# xininfo: To get the width (pixels) of the biggest attached monitor.
#       Install: https://github.com/DaveDavenport/xininfo
##


CACHE_DIR=~/.cache/wallgig/


WIDTH=$(xininfo --max-mon-width)

BG_SET_CMD="MultiMonitorBackground -clip -input"
CURL="curl "
PURITY=sfw

##
# Stuff we do not want to see
##
EXCLUDE_TAGS=( 'women' 'anime' 'anime-girls' 'cars' 'car' )

##
# Stuff we do want to see
##
TAGS=(  'road'  'nature' 'landscapes' 'ocean' 'forest' )


##
# Create cache directory
##
if [ -n "${CACHE_DIR}" ] && [ ! -d ${CACHE_DIR} ]
then
    mkdir -p "${CACHE_DIR}"
fi


##
# Construct Download URL
##
URL="http://wallgig.net/?order=random&per_page=40&purity\[\]=${PURITY}"

# Add exclude tags.
for ET in ${EXCLUDE_TAGS[@]}
do
    URL="${URL}&exclude_tags\[\]=${ET}"
done

#Pick a random tag we want to show.
if [ "${#TAGS[@]}" -gt 0 ]
then
    RIMG=$(( ${RANDOM} % ${#TAGS[@]}))
    ET=${TAGS[ ${RIMG}] }
    URL="${URL}&tags\[\]=${ET}"
    echo "Selected tag: ${TAGS[${RIMG}]}"
fi

# Set width preferences
if [ -n ${WIDTH} ]
then
    URL="${URL}&width=${WIDTH}"
fi


echo "Fetching list of images." 
# Get list of IDS
IDS=( $(${CURL} "$URL" 2>/dev/null | grep "data-wallpaper-id" | sed  "s|.*data-wallpaper-id='\(.*\)'.*|\1|g") )

# Check results
if [ ${#IDS[@]} -eq 0 ]
then
    if [ -n "${CACHE_DIR}" ] 
    then
        IMAGE=$(cat previous_ids | sort -n | uniq -c | sort | head -n1 | awk '{print $2}') 
        echo ${IMAGE} >> previous_ids
        ${BG_SET_CMD} ${CACHE_DIR}/${IMAGE}.jpg 
        exit 0;
    else
        echo "No Wallpapers found"
        exit 1;
    fi
fi

echo "Got ${#IDS[@]} images."

# Pick random image
SELECTED_IMAGE=$(( ${RANDOM} % ${#IDS[@]} ))

echo ${IDS[${SELECTED_IMAGE}]} >> previous_ids

# Create url for image specific page
URL="http://wallgig.net/wallpapers/${IDS[${SELECTED_IMAGE}]}/"

# Get wallpaper url from the image page
echo Fetching location for image id: ${IDS[${SELECTED_IMAGE}]}
WP_PATH=$(${CURL} "$URL" 2>/dev/null | grep \<img.*img-wallpaper | sed 's|.*src="\(.*\)" width.*|\1|')

##
# If cache is set, lookup image in cache, otherwise fetch it.
##
if [ -n "${CACHE_DIR}" ]
then
    CACHE_FILE="${CACHE_DIR}/${IDS[${SELECTED_IMAGE}]}.jpg"

    if [ -f ${CACHE_FILE} ]
    then
        echo Get image from cache: ${CACHE_FILE}
        ${BG_SET_CMD} ${CACHE_FILE} 
    elif [ -n "${WP_PATH}" ]
    then
        echo Get image: ${WP_PATH}
        ${CURL} "${WP_PATH}" -o ${CACHE_FILE} 2>/dev/null
        ${BG_SET_CMD} ${CACHE_FILE} 
    fi
else 
    ${CURL} "${WP_PATH}" -o /tmp/wallpaper.jpg 2>/dev/null
    ${BG_SET_CMD} /tmp/wallpaper.jpg 
fi
