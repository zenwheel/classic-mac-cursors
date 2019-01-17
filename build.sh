#!/bin/sh

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

echo "Building in $SCRIPTPATH..."

mkdir -p "$SCRIPTPATH/build/16x16"
mkdir -p "$SCRIPTPATH/build/32x32"
mkdir -p "$SCRIPTPATH/build/64x64"

for FILE in "$SCRIPTPATH"/*.cur; do
	echo "Processing $FILE..."
	F=$(basename "$FILE")
	NAME=$(echo "$F" | sed 's/\.[^\.]*$//')
	HOTSPOT=$(file "$FILE" | sed 's/.*hotspot @//')
	echo "Hot Spot for $NAME is $HOTSPOT"
	convert "$FILE" -crop 16x16+0+0 "$SCRIPTPATH/build/16x16/$NAME.png"
	convert "$SCRIPTPATH/build/16x16/$NAME.png" -scale 32x32 "$SCRIPTPATH/build/32x32/$NAME.png"
	convert "$SCRIPTPATH/build/16x16/$NAME.png" -scale 64x64 "$SCRIPTPATH/build/64x64/$NAME.png"
done

