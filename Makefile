TEMPORARY_FOLDER?=$(HOME)/tmp
PREFIX?=/usr/local/AppTool/Taylor
BUILD_TOOL?=xcodebuild
PACKAGE_NAME?=Taylor.app
BUILD_DESTINATION?=$(TEMPORARY_FOLDER)/Build/Products/Release

XCODEFLAGS=-scheme Taylor -derivedDataPath $(TEMPORARY_FOLDER)/ -configuration Release

.PHONY: build install install_homebrew 

build:
	$(BUILD_TOOL) $(XCODEFLAGS) build

install:
	make build
	mkdir -p "$(PREFIX)"

	cp -rf "$(TEMPORARY_FOLDER)/Build/Products/Release/$(PACKAGE_NAME)" "$(PREFIX)/bin/"
	ln -sf "$(PREFIX)/bin/Contents/MacOS/Taylor" "/usr/local/bin/taylor"
	make remove

install_homebrew:
	make build
	mkdir -p "$(PREFIX)/Frameworks" "$(PREFIX)/bin"
	cp -f "$(BUILD_DESTINATION)/$(PACKAGE_NAME)/Contents/MacOS/Taylor" "$(PREFIX)/bin/taylor"
	cp -Rf "$(BUILD_DESTINATION)/$(PACKAGE_NAME)/Contents/Frameworks/" "$(PREFIX)/Frameworks/"
	make remove

remove:
	rm -rf $(TEMPORARY_FOLDER)
