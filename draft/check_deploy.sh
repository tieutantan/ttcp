#!/bin/bash

# Current commit
LAST_COMMIT=$(git rev-parse HEAD)

# Current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# On current branch fetch all updates from remote repository
git fetch --all

# Reset to the latest commit on the current branch
git reset --hard origin/"$CURRENT_BRANCH"

# Check if the last commit is different from the current commit
if [ "$LAST_COMMIT" != "$(git rev-parse HEAD)" ]; then
  git pull # Pull the latest changes from the remote repository
  npm install
  npm run build
fi