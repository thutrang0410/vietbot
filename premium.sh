#!/bin/sh

progress_download() {
    url="$1"
    output="$2"
    name="$3"

    echo "Đang tải $name..."

    curl -L -s "$url" -o "$output" &
    pid=$!

    i=0
    chars="##########"

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i + 1) % 10 ))

        printf "\r[%.*s%-*s]" \
        "$i" "$chars" \
        "$((10 - i))" ""

        sleep 0.2
    done

    wait $pid

    printf "\r[##########] 100%%\n"
}

echo ""
echo "===================================="
echo "||  CÀI ĐẶT VIETBOT BY THU TRANG  ||"
echo "===================================="
echo ""

if command -v pkg >/dev/null 2>&1; then
    echo "=====> Cài qua Termux <====="
    echo ""
    echo "Vui lòng chờ cài đặt các gói."
    echo ""

    pkg upgrade -y >/dev/null 2>&1
    pkg install -y curl >/dev/null 2>&1

elif command -v apk >/dev/null 2>&1; then
    echo "=====> Cài qua iSH <====="
    echo ""
    echo "Vui lòng chờ cài đặt các gói."
    echo ""

    apk add curl >/dev/null 2>&1

else
    echo "Lỗi Script"
    exit 1
fi

echo "Đã cài thành công, chờ xoá bộ nhớ cũ."
echo ""

rm -f "$HOME"/*.apk >/dev/null 2>&1
rm -f "$HOME"/*.sh >/dev/null 2>&1

echo "Đã xoá bộ nhớ."
echo ""

progress_download \
"https://raw.githubusercontent.com/thutrang0410/vietbot/main/download.sh" \
"$HOME/download.sh" \
"Script"

progress_download \
"https://raw.githubusercontent.com/thutrang0410/vietbot/main/dlna-uni.sh" \
"$HOME/dlna-uni.sh" \
"Logic Âm thanh"

progress_download \
"https://raw.githubusercontent.com/thutrang0410/vietbot/main/install.sh" \
"$HOME/install.sh" \
"Cấu hình"

chmod +x "$HOME/download.sh"
chmod +x "$HOME/install.sh"
chmod +x "$HOME/dlna-uni.sh"

echo ""
echo "[1/3] Chuẩn bị cài đặt."
"$HOME/download.sh"

echo ""
echo "[2/3] Cài đặt Vietbot."
"$HOME/install.sh" || true

echo ""
echo "[3/3] Cài đặt Âm thanh."
"$HOME/dlna-uni.sh" 192.168.43.1:5555

echo ""
echo "Cài đặt hoàn tất."
echo "Vào wifi Phicomm R1, truy cập http://192.168.43.1:8081 để cấu hình Wi-Fi cho thiết bị."
