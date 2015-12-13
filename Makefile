TEMPORARY_FOLDER?=$(HOME)/tmp
PREFIX?=/usr/local
BUILD_TOOL?=xcodebuild

XCODEFLAGS=-scheme Taylor -derivedDataPath $(TEMPORARY_FOLDER)/ -configuration Release

.PHONY: build install remove 

build:
	$(BUILD_TOOL) $(XCODEFLAGS) build

install:
	make build
	$(TEMPORARY_FOLDER)/Build/Products/Release/Taylor.app/Contents/Resources/install
	make remove

remove:
	rm -rf $(TEMPORARY_FOLDER)

	