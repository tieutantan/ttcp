#!/bin/bash

# Current commit
LAST_COMMIT=$(git rev-parse HEAD)

# Current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

#  on current branch Fetch all updates from remote repository
git fetch --all

# Reset to the latest commit on the current branch
git reset --hard origin/"$CURRENT_BRANCH"

# run git pull and check if there are any changes if yes then run npm install and npm run build
if [ "$LAST_COMMIT" != "$(git rev-parse HEAD)" ]; then
  npm install
  npm run build
fi

