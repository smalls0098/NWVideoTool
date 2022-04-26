.PHONY: default
default:
	echo "USAGE: make create/lint/push"

.PHONY: create
create:
	pod lib create NWVideoTool

.PHONY: lint 
lint:
	pod spec lint NWVideoTool.podspec --allow-warnings --no-clean --verbose

.PHONY: push
push:
	pod spec lint NWVideoTool.podspec --allow-warnings
	pod trunk push NWVideoTool.podspec --allow-warnings --allow-warnings

