#!/bin/bash

# Current commit
LAST_COMMIT=$(git rev-parse HEAD)

# Current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

#  on current branch Fetch all updates from remote repository
git fetch --all

# Reset to the latest commit on the current branch
git reset --hard origin/"$CURRENT_BRANCH"

# Kiểm tra nếu commit hiện tại khác commit mới nhất trên branch hiện tại
if [ "$LAST_COMMIT" != "$(git rev-parse origin/"$CURRENT_BRANCH")" ]; then
    echo "Có commit mới tại $(pwd). Đang pull code về..."
    git pull origin "$CURRENT_BRANCH"
    # Chạy các lệnh setup riêng cho thư mục này (tuỳ chỉnh nếu cần)
    npm install
    npm run build
else
    echo "Không có commit mới tại $(pwd)."
fi

# run git pull and check if there are any changes if yes then run npm install and npm run build
# if no then do nothing
# this script will be run in all the directories where we have the codebase


