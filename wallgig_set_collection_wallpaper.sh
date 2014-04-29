#!/bin/bash

##
# wallgig_set_collection_wallpaper.sh
# Written by: qball _at_ gmpclient _dot_ org
#
# Script fetches a random wallpaper from wallgig.net collection and sets this as background.
#
# This script is public domain, you are free todo whatever you like with it.
# The tools by this script are not!
#
# Script uses the following external tools, drop in replacements can be inserted:
# Curl: To fetch data from the interwebs
#       Install: See package manager.
# MultiMonitorBackground: Set background wallpaper (multi monitor aware)
#       Install: https://github.com/DaveDavenport/MultiMonitorBackground
##

# Directory of cache dir.
CACHE_DIR=~/.cache/wallgig_collection/
# File holding ids of previous images.
PREVIOUS_IDS_LIST=~/.wallgig_collection_prev_id
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

# The collection to fetch images for.
COLLECTION="682-qball-s-wallpapers"

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
URL="http://wallgig.net/collections/${COLLECTION}"

echo "Fetching list of images."
# Get list of IDS
IDS=( $(download_ids "$URL")  )
declare -i CONTINUE=1
declare -i page=2
while [[ ${CONTINUE} = 1 ]]
do
    NEW_IDS=( $(download_ids "$URL?page=$page") ) 
    echo "Got ${#NEW_IDS[@]} images: $page $URL&page=$page"
    if [[ ${#NEW_IDS[@]} = 0 ]]
    then
        CONTINUE=2;
    else
        IDS=( ${IDS[@]} ${NEW_IDS[@]} ) 
    fi
    page=$page+1
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
