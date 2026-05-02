#!/bin/sh

ADB_DEVICE="$1"
ADB="adb"
RECONNECT_COUNT=0
MAX_RECONNECT=999

DLNA_APK_NAME="auto-dlna.apk"
DLNA_APK_LOCAL_PATH="$HOME/$DLNA_APK_NAME"
DLNA_APK_REMOTE_PATH="/data/local/tmp/$DLNA_APK_NAME"

UNISOUND_APK_NAME="uni-sound.apk"
UNISOUND_APK_LOCAL_PATH="$HOME/$UNISOUND_APK_NAME"
UNISOUND_APK_REMOTE_PATH="/data/local/tmp/$UNISOUND_APK_NAME"

adb_exec() {
    "$ADB" "$@"
}

is_device_connected() {
    "$ADB" devices 2>/dev/null | awk -v dev="$ADB_DEVICE" '$1==dev && $2=="device" {found=1} END {exit (found?0:1)}'
}

log_info() {
    echo "[Trhieu] $*"
}

connect_adb() {
    log_info "Khoi dong lai ket noi ADB..."
    while true; do
        "$ADB" kill-server
        "$ADB" connect "$ADB_DEVICE"
        if is_device_connected; then
            return
        fi
        log_info "Chua ket noi duoc $ADB_DEVICE, thu lai..."
        sleep 2
    done
}

ensure_device_connection() {
    if is_device_connected; then
        return
    fi
    connect_adb
}

step_push_apk() {
    local apk_path="$1"
    local apk_remote_path="$2"
    adb_exec push "$apk_path" "$apk_remote_path"
}

step_install_apk() {
    local name="$1"
    local path="$2"
    log_info "Cai dat $name..."
    adb_exec shell /system/bin/pm install -r "$path"
}

step_reboot_device() {
    log_info "Khoi dong lai thiet bi..."
    adb_exec reboot &
}

step_hide_packages() {
    log_info "Vo hieu hoa bloatware..."
    local apps="device airskill exceptionreporter systemtool otaservice productiontest bugreport"
    for app in $apps; do
        log_info "Hide com.phicomm.speaker.$app"
        adb_exec shell /system/bin/pm hide "com.phicomm.speaker.$app"
    done
}

step_unhide_packages() {
    log_info "Kich hoat lai player"
    local apps="player"
    for app in $apps; do
        log_info "Unhide com.phicomm.speaker.$app"
        adb_exec shell /system/bin/pm unhide "com.phicomm.speaker.$app"
    done
}

allow_install_non_market_apps() {
    adb_exec shell settings put secure install_non_market_apps 1
}

ensure_device_connection
allow_install_non_market_apps

step_push_apk "$DLNA_APK_LOCAL_PATH" "$DLNA_APK_REMOTE_PATH"
step_install_apk "$DLNA_APK_NAME" "$DLNA_APK_REMOTE_PATH"

step_push_apk "$UNISOUND_APK_LOCAL_PATH" "$UNISOUND_APK_REMOTE_PATH"
step_install_apk "$UNISOUND_APK_NAME" "$UNISOUND_APK_REMOTE_PATH"

step_hide_packages
step_unhide_packages
step_reboot_device
