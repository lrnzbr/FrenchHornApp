#!/bin/sh
echo ">>> SETING UP ENVIRONMENT"


echo ">>> UPDATING BUILD NUMBER: $CI_BUILD_NUMBER"

plutil -replace CFBundleVersion -string "$CI_BUILD_NUMBER" $CI_PRIMARY_REPOSITORY_PATH/FrenchHornApp/Info.plist
plutil -replace CFBundleShortVersionString -string "1.2.${CI_BUILD_NUMBER}" $CI_PRIMARY_REPOSITORY_PATH/FrenchHornApp/Info.plist
