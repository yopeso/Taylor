TEMPORARY_FOLDER?=$(HOME)/tmp
PREFIX?=/usr/local/tools/Taylor
MAKE_SYMLINKS?=yes
BUILD_TOOL?=xcodebuild
PACKAGE_NAME?=Taylor.app
BUILD_DESTINATION?=$(TEMPORARY_FOLDER)/Build/Products/Release

XCODEFLAGS=-scheme Taylor -derivedDataPath $(TEMPORARY_FOLDER)/ -configuration Release

BUILD_COMMAND=$(BUILD_TOOL) $(XCODEFLAGS) build

.PHONY: build install

build:
ifneq ($(strip $(shell command -v xcpretty)),)
	$(BUILD_COMMAND) | xcpretty
else
	$(BUILD_COMMAND)
endif

install:
	make build

	ditto "$(BUILD_DESTINATION)/$(PACKAGE_NAME)/Contents/MacOS/Taylor" "$(PREFIX)/bin/taylor"
	ditto "$(BUILD_DESTINATION)/$(PACKAGE_NAME)/Contents/Frameworks/" "$(PREFIX)/Frameworks/"
ifeq ($(MAKE_SYMLINKS),yes)
	ln -sf "$(PREFIX)/bin/taylor" "/usr/local/bin/taylor"
endif

	make remove

remove:
	rm -rf $(TEMPORARY_FOLDER)
