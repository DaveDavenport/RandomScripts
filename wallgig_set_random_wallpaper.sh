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


WALLGIG_FUNCTIONS=wallgig.func
if [ ! -f ${WALLGIG_FUNCTIONS} ]
then
    echo "Failed to find: ${WALLGIG_FUNCTIONS}"
    exit 1;
fi 
source wallgig.func

# Number of pages to get.
PAGE_NUMBERS=5

##
# Wallgig configuration
##

PURITY=sfw

##
# Stuff we do not want to see
##
EXCLUDE_TAGS=( 'anime' 'anime-girls' 'anime+girls' 'cleavage' )

EXCLUDE_CATEGORIES=( 'People' 'Games' 'Vehicles' 'Anime+%2F+Manga')

##
# Stuff we do want to see
##
TAGS=( 'flags' 'road'  'nature' 'landscapes' 'ocean' 'forest' 'roads' 'forests' 'landscape' 'cityscape')


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

# Add exclude categories.
for EC in ${EXCLUDE_CATEGORIES[@]}
do
    URL="${URL}&exclude_categories\[\]=${EC}"
done

#Pick a random tag we want to show.

URL="${URL}&tags%3A("
for TAG in ${TAGS[@]}
do
    if [ $TAG = ${TAGS[$((${#TAGS[@]}-1))]} ]
    then
        URL="${URL}${TAG})"
    else
        URL="${URL}${TAG}+OR+"
    fi
done

# Set width preferences
if [ -n ${WIDTH} ]
then
    URL="${URL}&width=${WIDTH}"
fi

echo "Fetching list of images."
# Get list of IDS
IDS=( $(download_ids "$URL") )


for page in `seq 1 ${PAGE_NUMBERS}`
do
    IDS=( ${IDS[@]} $(download_ids "$URL&page=$page") )
done

echo "Got ${#IDS[@]} numbers"

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

set_image "${IMAGE_ID}"
