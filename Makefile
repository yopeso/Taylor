TEMPORARY_FOLDER?=$(HOME)/tmp
PREFIX?=/usr/local/tools/Taylor
BUILD_TOOL?=xcodebuild
PACKAGE_NAME?=Taylor.app
BUILD_DESTINATION?=$(TEMPORARY_FOLDER)/Build/Products/Release

XCODEFLAGS=-scheme Taylor -derivedDataPath $(TEMPORARY_FOLDER)/ -configuration Release

.PHONY: build install

build:
	$(BUILD_TOOL) $(XCODEFLAGS) build

install:
	make build

	ditto "$(BUILD_DESTINATION)/$(PACKAGE_NAME)/Contents/MacOS/Taylor" "$(PREFIX)/bin/taylor"
	ditto "$(BUILD_DESTINATION)/$(PACKAGE_NAME)/Contents/Frameworks/" "$(PREFIX)/Frameworks/"
	ln -sf "$(PREFIX)/bin/taylor" "/usr/local/bin/taylor"
	
	make remove

remove:
	rm -rf $(TEMPORARY_FOLDER)
