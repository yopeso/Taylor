#! /bin/bash

CONFIGURATION="Release"
BUILD_DIR="./build"
CMD="xcodebuild -scheme Taylor -sdk macosx -configuration ${CONFIGURATION} build -derivedDataPath ${BUILD_DIR}"

which -s xcpretty
XCPRETTY_INSTALLED=$?

if [[ $TRAVIS || $XCPRETTY_INSTALLED == 0 ]]; then
  eval "${CMD} | xcpretty"
else
  eval "$CMD"
fi

echo "Checking app integrity"
BINARY="${BUILD_DIR}/Build/Products/${CONFIGURATION}/Taylor.app/Contents/MacOS/Taylor"
if eval "${BINARY} --version"; then
  echo "App OK"
fi

