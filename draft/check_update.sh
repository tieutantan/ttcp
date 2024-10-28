#!/bin/bash

# Kiểm tra commit hiện tại
LAST_COMMIT=$(git rev-parse HEAD)

# Fetch cập nhật từ remote mà không merge
git fetch origin

# Kiểm tra nếu commit hiện tại khác commit mới nhất trên branch
if [ "$LAST_COMMIT" != "$(git rev-parse origin/$(git rev-parse --abbrev-ref HEAD))" ]; then
    echo "Có commit mới tại $(pwd). Đang pull code về..."
    git pull origin $(git rev-parse --abbrev-ref HEAD)
    
    # Chạy các lệnh setup riêng cho thư mục này (tuỳ chỉnh nếu cần)
    npm install
    npm run build
else
    echo "Không có commit mới tại $(pwd)."
fi
