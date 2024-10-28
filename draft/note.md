chmod +x /path/to/repo1/check_update.sh
chmod +x /path/to/repo2/check_update.sh
# Thực hiện tương tự cho các repo khác

Bước 3: Thiết lập cron job để chạy check_all_updates.sh mỗi phút

Mở crontab để chỉnh sửa:

crontab -e

Thêm dòng sau vào crontab để chạy script mỗi phút:

* * * * * /path/to/check_all_updates.sh >> /path/to/logfile.log 2>&1

Với cấu hình này, check_all_updates.sh sẽ tự động gọi từng check_update.sh trong các thư mục, giúp mỗi thư mục tự kiểm tra và cập nhật riêng.