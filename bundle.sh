#!/bin/bash

set -e

DIST="dist"
EXE_NAME="react-flux-example"

PROD_FILE="$DIST/all_prod.js"
DEV_FILE="$DIST/all_dev.js"

PREPEND_JS="(function(global, React, ReactDOM, ReactIntl) {"
APPEND_JS="})(window, window['React'], window['ReactDOM'], window['ReactIntl']);"

mkdir -p $DIST
rm -rf $PROD_FILE
rm -rf $DEV_FILE

echo "Stack build ..."
stack build --fast --pedantic

echo "Adding stubs ..."
tmpfile=$(mktemp /tmp/rawapp.XXXXXX)
echo "$PREPEND_JS" | cat - $(stack path --local-install-root)/bin/$EXE_NAME.jsexe/all.js > $tmpfile
echo "$APPEND_JS" >> $tmpfile
sed -i -- 's/goog.provide.*//' $tmpfile
sed -i -- 's/goog.require.*//' $tmpfile
cp $tmpfile $DEV_FILE

echo "Building dependencies ... "
$(npm bin)/browserify export.js > "$DIST/bundle.js"

echo "Building production bundle ... "
tmpbundle=$(mktemp /tmp/prodb.XXXXXX)
cp "$DIST/bundle.js" "$tmpbundle"
sed -i -- 's/process.env.NODE_ENV/"production"/' "$tmpbundle"
$(npm bin)/uglifyjs --compress warnings=false --mangle -- "$tmpbundle" "$DEV_FILE" >> "$PROD_FILE"

echo "Copying needed css files ... "
cp node_modules/leaflet/dist/leaflet.css "$DIST/leaflet.css"

echo "Generating index.html ..."
cp index.html "$DIST/index.html"
cp index_dev.html "$DIST/index_dev.html"
