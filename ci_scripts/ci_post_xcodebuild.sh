#!/bin/bash

# Step 1: Get the build number from the environment variable
BUILD_NUMBER=$CI_BUILD_NUMBER

# Step 2: Define the tag name
TAG_NAME="build-$BUILD_NUMBER"

# Step 3: Create a new tag
git tag $TAG_NAME

# Step 4: Push the tag to the GitHub repository
# Replace 'origin' with your remote name if it's different
git push origin $TAG_NAME

echo "Tagged the repository with $TAG_NAME"
