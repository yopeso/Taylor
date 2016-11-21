#! /bin/bash

CMD="xcodebuild -scheme Taylor -sdk macosx build"

which -s xcpretty
XCPRETTY_INSTALLED=$?

if [[ $TRAVIS || $XCPRETTY_INSTALLED == 0 ]]; then
  eval "${CMD} | xcpretty"
else
  eval "$CMD"
fi
