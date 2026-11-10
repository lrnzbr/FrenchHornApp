#!/bin/sh
# Xcode Cloud owns the build number; the project owns the marketing version.
# Info.plist expands both build settings, keeping local and Cloud archives aligned.
set -eu

echo ">>> SETTING UP ENVIRONMENT"

BUILD="${CI_BUILD_NUMBER:?CI_BUILD_NUMBER is unset}"
REPO="${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is unset}"
PBXPROJ="${REPO}/FrenchHornApp.xcodeproj/project.pbxproj"

echo ">>> UPDATING VERSIONS FOR BUILD: ${BUILD}"

case "${BUILD}" in
	''|*[!0-9]*) echo "error: CI_BUILD_NUMBER must be a positive integer" >&2; exit 1 ;;
esac
if [ "${BUILD}" -lt 1 ]; then
	echo "error: CI_BUILD_NUMBER must be a positive integer" >&2
	exit 1
fi
if [ ! -f "${PBXPROJ}" ]; then
	echo "error: project.pbxproj not found at ${PBXPROJ}" >&2
	exit 1
fi

sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9][0-9]*;/CURRENT_PROJECT_VERSION = ${BUILD};/g" "${PBXPROJ}"

echo ">>> Done."
