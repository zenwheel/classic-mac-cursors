#!/bin/sh

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
NAME="classic-mac-cursors"
THEME_DIR="$SCRIPTPATH/$NAME"
THEME_ARCHIVE="$SCRIPTPATH/$NAME.tar.gz"

rm -rf "$SCRIPTPATH/build"
rm -rf "$THEME_DIR"

mkdir -p "$SCRIPTPATH/build/16x16"
mkdir -p "$SCRIPTPATH/build/32x32"
mkdir -p "$SCRIPTPATH/build/64x64"
mkdir -p "$THEME_DIR/cursors"

ruby "$SCRIPTPATH/render-curs.rb" "$SCRIPTPATH/src/"*.rez

for CUR in "$SCRIPTPATH/build"/*.config; do
	BASENAME=$CUR
	BASENAME=${BASENAME##*/}
	BASENAME=${BASENAME%.*}

	xcursorgen -p "$SCRIPTPATH/build" "$CUR" "$THEME_DIR/cursors/$BASENAME"
done

while read -r ALIAS ; do
	FROM=${ALIAS% *}
	TO=${ALIAS#* }

	if [ -e "$THEME_DIR/cursors/$FROM" ]; then
		continue
	fi
	echo "linking $FROM -> $TO"
	(cd "$THEME_DIR/cursors"; ln -sf "$TO" "$FROM")
done < "$SCRIPTPATH/aliases"

cp "$SCRIPTPATH/cursor.theme" "$THEME_DIR/"
(cd "$SCRIPTPATH"; tar czvf "$THEME_ARCHIVE" "$NAME")
