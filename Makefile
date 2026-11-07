.PHONY: app test run

app:
	./Scripts/build-app.sh

test:
	swift test --scratch-path "$${TMPDIR%/}/app-cliner-build"

run: app
	open build/Banish.app
