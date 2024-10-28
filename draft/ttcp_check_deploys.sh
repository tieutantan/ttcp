#!/bin/bash

# Danh sách các thư mục chứa file check_update.sh
REPO_DIRS=(
    "/path/to/repo1"
    "/path/to/repo2"
    "/path/to/repo3"
)

for REPO_DIR in "${REPO_DIRS[@]}"; do
    echo "Đang kiểm tra cập nhật cho $REPO_DIR..."
    
    # Chạy file check_update.sh trong từng thư mục
    "$REPO_DIR/check_deploy.sh"
done