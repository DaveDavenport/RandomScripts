#!/bin/bash

##
# Script uses the following external tools:
# Curl: To fetch data from the interwebs
#       Install: See package manager.
# MultiMonitorBackground: Set background wallpaper (multi monitor aware)
#       Install: https://github.com/DaveDavenport/MultiMonitorBackground
# xininfo: To get the width (pixels) of the biggest attached monitor.
#       Install: https://github.com/DaveDavenport/xininfo
##

WIDTH=$(xininfo --max-mon-width)

BG_SET_CMD="MultiMonitorBackground -clip -input"
CURL="curl "
PURITY=sfw

##
# Stuff we do not want to see
##
EXCLUDE_TAGS=( 'women' 'anime' 'anime-girls' 'cars' )

##
# Stuff we do want to see
##
TAGS=(  'road'  'nature' 'landscapes' 'ocean' 'forest' )

URL="http://wallgig.net/?order=random&per_page=40&purity\[\]=${PURITY}"

for ET in ${EXCLUDE_TAGS[@]}
do
    URL="${URL}&exclude_tags\[\]=${ET}"
done

if [ "${#TAGS[@]}" -gt 0 ]
then
    RIMG=$(( ${RANDOM} % ${#TAGS[@]}))
    ET=${TAGS[ ${RIMG}] }
    URL="${URL}&tags\[\]=${ET}"
fi

if [ -n ${WIDTH} ]
then
    URL="${URL}&width=${WIDTH}"
fi


echo "Fetching url: ${URL}"
# Get list of IDS
IDS=( $(${CURL} "$URL" | grep "data-wallpaper-id" | sed  "s|.*data-wallpaper-id='\(.*\)'.*|\1|g") )


#list ids
echo ${IDS[@]}

# Check results
if [ ${#IDS[@]} -eq 0 ]
then
    echo "No Wallpapers found"
    exit 1;
fi


SELECTED_IMAGE=$(( ${RANDOM} % ${#IDS[@]} ))

echo ${IDS[${SELECTED_IMAGE}]} >> previous_ids

URL="http://wallgig.net/wallpapers/${IDS[${SELECTED_IMAGE}]}/"

# Get wallpaper url
echo Fetching url: ${URL}
WP_PATH=$(${CURL} "$URL" | grep \<img.*img-wallpaper | sed 's|.*src="\(.*\)" width.*|\1|')

echo WP_PATH: ${WP_PATH}

if [ -n "${WP_PATH}" ]
then
    ${CURL} "${WP_PATH}" -o wallpaper.jpg
    ${BG_SET_CMD} wallpaper.jpg
fi
