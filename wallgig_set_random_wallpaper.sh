#!/bin/bash

WIDTH=1980

BG_SET_CMD="MultiMonitorBackground -clip -input"
PURITY=sfw
EXCLUDE_TAGS=( 'women' 'anime' 'anime-girls' )

URL="http://wallgig.net/?order=random&per_page=5&purity\[\]=${PURITY}"

for ET in ${EXCLUDE_TAGS[@]}
do
    URL="${URL}&exclude_tags\[\]=${ET}"
done

if [ -n ${WIDTH} ]
then
    URL="${URL}&width=${WIDTH}"
fi


echo "Fetching url: ${URL}"
# Get list of IDS
IDS=( $(curl "$URL" | grep "data-wallpaper-id" | sed  "s|.*data-wallpaper-id='\(.*\)'.*|\1|g") )


#list ids
echo ${IDS[@]}

# Check results
if [ ${#IDS[@]} -eq 0 ]
then
    echo "No Wallpapers found"
    exit 1;
fi

URL="http://wallgig.net/wallpapers/${IDS[0]}/"

# Get wallpaper url
echo Fetching url: ${URL}
WP_PATH=$(curl "$URL" | grep \<img.*img-wallpaper | sed 's|.*src="\(.*\)" width.*|\1|')

echo WP_PATH: ${WP_PATH}

if [ -n "${WP_PATH}" ]
then
    curl "${WP_PATH}" -o wallpaper.jpg
    ${BG_SET_CMD} wallpaper.jpg
fi
