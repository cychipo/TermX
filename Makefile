.PHONY: generate build dev run open rerun clean

PROJECT := TermX.xcodeproj
SCHEME := TermX
CONFIGURATION := Debug
DERIVED_DATA := .derived-data
APP := $(DERIVED_DATA)/Build/Products/$(CONFIGURATION)/TermX.app
BINARY := $(APP)/Contents/MacOS/TermX

generate:
	xcodegen generate --spec project.yml

build:
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIGURATION) \
		-derivedDataPath $(DERIVED_DATA) \
		build

dev: build
	open $(APP)

run: build
	$(BINARY)

open:
	open $(APP)

rerun:
	-killall TermX
	while pgrep -x TermX >/dev/null; do sleep 0.1; done
	open $(APP)

clean:
	rm -rf $(DERIVED_DATA)
