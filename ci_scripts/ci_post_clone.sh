#!/bin/sh
# Bumps CFBundleVersion / CFBundleShortVersionString for Xcode Cloud builds.
# MARKETING_VERSION + CURRENT_PROJECT_VERSION must exist in the target — Xcode
# merges them into the app Info.plist; without them you can get
# "Could not find CFBundleShortVersionString in Info.plist" during validation.
set -eu

echo ">>> SETTING UP ENVIRONMENT"

BUILD="${CI_BUILD_NUMBER:?CI_BUILD_NUMBER is unset}"
REPO="${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is unset}"
INFO_PLIST="${REPO}/FrenchHornApp/Info.plist"
PBXPROJ="${REPO}/FrenchHornApp.xcodeproj/project.pbxproj"

echo ">>> UPDATING VERSIONS FOR BUILD: ${BUILD}"

if [ ! -f "${INFO_PLIST}" ]; then
	echo "error: Info.plist not found at ${INFO_PLIST}" >&2
	exit 1
fi
if [ ! -f "${PBXPROJ}" ]; then
	echo "error: project.pbxproj not found at ${PBXPROJ}" >&2
	exit 1
fi

plutil -replace CFBundleVersion -string "${BUILD}" "${INFO_PLIST}"
plutil -replace CFBundleShortVersionString -string "1.2.${BUILD}" "${INFO_PLIST}"

# Keep pbxproj in sync so synthesized Info.plist processing sees the same versions.
sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9][0-9]*;/CURRENT_PROJECT_VERSION = ${BUILD};/g" "${PBXPROJ}"
sed -i '' "s/MARKETING_VERSION = [0-9.][0-9.]*;/MARKETING_VERSION = 1.2.${BUILD};/g" "${PBXPROJ}"

echo ">>> Done."
