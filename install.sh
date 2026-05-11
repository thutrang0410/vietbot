#!/bin/sh
APK_NAME="premium.apk"
APK_PATH="$HOME/$APK_NAME"
ADB_DEVICE_IP="192.168.43.1"
ADB_DEVICE_PORT="5555"
ADB_DEVICE="$ADB_DEVICE_IP:$ADB_DEVICE_PORT"
APK_REMOTE_PATH="/data/local/tmp/$APK_NAME"
PACKAGE_NAME="info.dourok.voicebot"
RECONNECT_COUNT=0
MAX_RECONNECT=999

ADB="adb"

log_info() {
    echo "[PHICOMM-R1] $*"
}

fail() {
    log_info "$1"
    exit 1
}

check_adb() {
    log_info "Kiểm tra ADB..."
    if ! command -v adb >/dev/null 2>&1; then
        log_info "ADB chưa được cài. Cài đặt android-tools..."
        if command -v apk >/dev/null 2>&1; then
            apk add --no-cache android-tools
        elif command -v pkg >/dev/null 2>&1; then
            pkg install -y android-tools
        else
            fail "Không tìm thấy trình quản lý phù hợp để cài đặt ADB. Vui lòng cài đặt ADB thủ công."
        fi
    fi
}

wait_for_wifi() {
    log_info "Kiểm tra kết nối WIFI tới $ADB_DEVICE_IP..."
    local wifi_prompt_shown=0
    while true; do
        if ping -c 1 -W 1 "$ADB_DEVICE_IP" >/dev/null 2>&1; then
            log_info "Đã ping thành công tới $ADB_DEVICE_IP."
            return
        fi
        if [ "$wifi_prompt_shown" -eq 0 ]; then
            log_info "Hãy kết nối tới Wifi của loa: Phicomm R1"
            wifi_prompt_shown=1
        fi
        sleep 3
    done
}

is_device_connected() {
    "$ADB" devices 2>/dev/null | awk -v dev="$ADB_DEVICE" '$1==dev && $2=="device" {found=1} END {exit (found?0:1)}'
}

ensure_device_connection() {
    wait_for_wifi
    if is_device_connected; then
        return
    fi
    connect_adb
}

adb_exec() {
    "$ADB" "$@"
}

reconnect_adb() {
    while true; do
        RECONNECT_COUNT=$((RECONNECT_COUNT + 1))
        if [ "$RECONNECT_COUNT" -gt "$MAX_RECONNECT" ]; then
            fail "Không thể kết nối ADB sau $MAX_RECONNECT lần thử."
        fi

        log_info "Mất kết nối ADB, thử kết nối lại (lần $RECONNECT_COUNT)..."
        wait_for_wifi
        "$ADB" connect "$ADB_DEVICE" >/dev/null 2>&1 || true
        sleep 2

        if is_device_connected; then
            RECONNECT_COUNT=0
            return
        fi
    done
}

connect_adb() {
    log_info "Khởi động lại kết nối ADB..."
    wait_for_wifi
    while true; do
        "$ADB" disconnect
        "$ADB" kill-server
        "$ADB" connect "$ADB_DEVICE"
        if is_device_connected; then
            return
        fi
        log_info "Chưa kết nối được $ADB_DEVICE, thử lại..."
        sleep 2
    done
}

step_hide_packages() {
    log_info "Vô hiệu hóa bloatware..."
    local apps="airskill exceptionreporter ijetty netctl systemtool otaservice productiontest bugreport"
    for app in $apps; do
        log_info "Vô hiệu $app"
        adb_exec shell /system/bin/pm hide "com.phicomm.speaker.$app"
    done
}

step_push_apk() {
    local apk_path="$1"
    local apk_remote_path="$2"
    adb_exec push "$apk_path" "$apk_remote_path"
}

step_uninstall_existing() {
    local package_name="$1"
    log_info "Kiểm tra làm sạch thiết bị trước khi cài đặt..."
    adb_exec shell /system/bin/pm uninstall "$package_name"
}

restore_packages() {
    log_info "Khôi phục các ứng dụng mặc định..."
    local apps="airskill exceptionreporter ijetty netctl otaservice systemtool productiontest bugreport"
    for app in $apps; do
        adb_exec shell /system/bin/pm unhide "com.phicomm.speaker.$app"
    done
}

step_install_apk() {
    local name="$1"
    local path="$2"
    log_info "Cài đặt $name..."
    adb_exec shell /system/bin/pm install -r "$path"
}

launch() {
    local name="$1"
    local main_activity="$2"
    log_info "Khởi động ứng dụng $name..."
    adb_exec shell am start -n "$main_activity"
}

check_adb
connect_adb
step_hide_packages

log_info "Đẩy APK lên thiết bị..."
step_push_apk "$APK_PATH" "$APK_REMOTE_PATH"
step_uninstall_existing "$PACKAGE_NAME"
step_install_apk "$APK_NAME" "$APK_REMOTE_PATH"
launch "$APK_NAME" "$PACKAGE_NAME/.java.activities.MainActivity"
