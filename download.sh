#!/bin/sh

APK_NAME="premium.apk"
APK_URL="https://github.com/thutrang0410/vietbot/releases/download/r1/$APK_NAME"
APK_PATH="$HOME/$APK_NAME"

DLNA_APK_NAME="auto-dlna.apk"
DLNA_APK_LOCAL_PATH="$HOME/$DLNA_APK_NAME"
DLNA_APK_URL="https://github.com/thutrang0410/vietbot/releases/download/r1/$DLNA_APK_NAME"

UNISOUND_APK_NAME="uni-sound.apk"
UNISOUND_APK_LOCAL_PATH="$HOME/$UNISOUND_APK_NAME"
UNISOUND_APK_URL="https://github.com/thutrang0410/vietbot/releases/download/r1/$UNISOUND_APK_NAME"

progress_download() {
    url="$1"
    output="$2"
    name="$3"

    echo "Đang tải $name..."

    total_size=$(curl -sIL "$url" | grep -i Content-Length | tail -1 | tr -d '\r' | awk '{print $2}')

    curl -L -sS "$url" -o "$output" >/dev/null 2>&1 &
    pid=$!

    while kill -0 $pid 2>/dev/null; do

        if [ -f "$output" ]; then
            current_size=$(wc -c < "$output" 2>/dev/null)

            if [ -n "$total_size" ] && [ "$total_size" -gt 0 ]; then

                percent=$((current_size * 100 / total_size))

                if [ "$percent" -gt 100 ]; then
                    percent=100
                fi

                bars=$((percent / 10))

                done_bar=$(printf "%${bars}s" | tr ' ' '#')

                printf "\r[%-10s] %3d%%" "$done_bar" "$percent"
            fi
        fi

        sleep 0.2
    done

    wait $pid

    printf "\r[##########] 100%%\n"
}

prepare_apk() {
    local apk_path="$1"
    local apk_url="$2"
    local apk_name="$3"

    progress_download "$apk_url" "$apk_path" "$apk_name"
}

prepare_apk "$APK_PATH" "$APK_URL" "$APK_NAME"
prepare_apk "$DLNA_APK_LOCAL_PATH" "$DLNA_APK_URL" "$DLNA_APK_NAME"
prepare_apk "$UNISOUND_APK_LOCAL_PATH" "$UNISOUND_APK_URL" "$UNISOUND_APK_NAME"
