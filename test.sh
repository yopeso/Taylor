#! /bin/bash

TEST_CMD="xcodebuild test -scheme Taylor -sdk macosx -enableCodeCoverage YES"

# Run without xcpretty due to a bug that leads to incorrect coverage data ¯\_(ツ)_/¯
eval "$TEST_CMD"
