#!/bin/sh
# Updates bundle versions before xcodebuild. Requires a committed Info.plist
# (INFOPLIST_FILE) because the target uses GENERATE_INFOPLIST_FILE — there was
# no on-disk plist before, so plutil failed and this script exited 1 on Xcode Cloud.
set -eu

echo ">>> SETTING UP ENVIRONMENT"

BUILD="${CI_BUILD_NUMBER:?CI_BUILD_NUMBER is unset}"
REPO="${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is unset}"
INFO_PLIST="${REPO}/FrenchHornApp/Info.plist"

echo ">>> UPDATING BUILD NUMBER: ${BUILD}"
echo "    ${INFO_PLIST}"

if [ ! -f "${INFO_PLIST}" ]; then
	echo "error: Info.plist not found at ${INFO_PLIST}" >&2
	exit 1
fi

plutil -replace CFBundleVersion -string "${BUILD}" "${INFO_PLIST}"
plutil -replace CFBundleShortVersionString -string "1.2.${BUILD}" "${INFO_PLIST}"

echo ">>> Done."
