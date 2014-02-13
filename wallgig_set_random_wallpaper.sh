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

# Directory of cache dir.
CACHE_DIR=~/.cache/wallgig/
# File holding ids of previous images.
PREVIOUS_IDS_LIST=~/.wallgig_prev_id
# Width of the largest monitor.
WIDTH=$(xininfo --max-mon-width)
# Command to set background. ${BG_SET_CMD} <file>
BG_SET_CMD="MultiMonitorBackground -clip -input"
# command to fetch url and output to stdout.
CURL="curl "

##
# Wallgig configuration
##

PURITY=sfw

##
# Stuff we do not want to see
##
EXCLUDE_TAGS=( 'women' 'anime' 'anime-girls' 'cars' 'car' )

##
# Stuff we do want to see
##
TAGS=(  'road'  'nature' 'landscapes' 'ocean' 'forest' 'roads' 'forests' 'landscape' )


##
# Create cache directory
##
if [ -n "${CACHE_DIR}" ] && [ ! -d ${CACHE_DIR} ]
then
    mkdir -p "${CACHE_DIR}"
fi

##
# @argument a wallgig image ID.
#
# Sets background image from Cache 
##
function cache_set_wallpaper()
{
    if [ -n "${CACHE_DIR}" ]
    then
        IMAGE_PATH="${CACHE_DIR}/$1.jpg"
        ${BG_SET_CMD} "${IMAGE_PATH}" 
    fi
}

##
# sorts, counts and gets the least viewed 
# cache image.
#
# @returns wallgig image id of least viewed image.
##
function get_least_viewed_cache_image()
{
    IMAGE_ID=$(cat "${PREVIOUS_IDS_LIST}" | sort -n | uniq -c | sort | head -n1 | awk '{print $2}') 
    echo "${IMAGE_ID}" 
}

##
# @argument wallgig image id.
#
# Get the download url for image with id. 
##
function fetch_image()
{
    URL="http://wallgig.net/wallpapers/$1/"
    WP_PATH=$(${CURL} "$URL" 2>/dev/null | grep \<img.*img-wallpaper | sed 's|.*src="\(.*\)" width.*|\1|')
    ${CURL} "${WP_PATH}" -o "$2" 2>/dev/null
}

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
        IMAGE_ID=$(get_least_viewed_cache_image )
        echo "Selected image from cache: ${IMAGE_ID}"
        echo ${IMAGE_ID} >> "${PREVIOUS_IDS_LIST}" 
        cache_set_wallpaper "${IMAGE_ID}"
        exit 0;
    else
        echo "No Wallpapers found"
        exit 1;
    fi
fi

# Pick random image
SELECTED_IMAGE=$(( ${RANDOM} % ${#IDS[@]} ))
IMAGE_ID="${IDS[${SELECTED_IMAGE}]}"

echo "Selected image: ${IMAGE_ID}"
# Store image
echo ${IMAGE_ID} >> ${PREVIOUS_IDS_LIST} 


##
# If cache is set, lookup image in cache, otherwise fetch it.
##
if [ -n "${CACHE_DIR}" ]
then
    CACHE_FILE="${CACHE_DIR}/${IMAGE_ID}.jpg"

    if [ -f ${CACHE_FILE} ]
    then
        echo Get image from cache: ${CACHE_FILE}
        cache_set_wallpaper "${IMAGE_ID}"
    else
        # Get wallpaper url from the image page
        echo Fetching location for image id: ${IMAGE_ID}
        fetch_image "${IMAGE_ID}" "${CACHE_FILE}"
        cache_set_wallpaper "${IMAGE_ID}"
    fi
else 
    # Get wallpaper url from the image page
    echo Fetching location for image id: ${IMAGE_ID}
    fetch_image "${IMAGE_ID}" "/tmp/wallpaper.jpg"
    ${BG_SET_CMD} /tmp/wallpaper.jpg 
fi
