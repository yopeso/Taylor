#! /bin/bash

CONFIGURATION="Release"
BUILD_DIR="./build"
TEST_CMD="xcodebuild test -scheme Taylor -sdk macosx -enableCodeCoverage YES -derivedDataPath ${BUILD_DIR}"

# Run without xcpretty due to a bug that leads to incorrect coverage data ¯\_(ツ)_/¯
eval "$TEST_CMD"
