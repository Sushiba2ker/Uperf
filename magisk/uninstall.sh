#!/system/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
# Enhanced for Google Tensor G3 by Sushiba
#

BASEDIR="$(dirname $(readlink -f "$0"))"
if [ -f "$BASEDIR/script/pathinfo.sh" ] && [ -f "$BASEDIR/script/libcommon.sh" ]; then
    . "$BASEDIR/script/pathinfo.sh"
    . "$BASEDIR/script/libcommon.sh"
else
    USER_PATH="/sdcard/Android/yc/uperf"
    wait_until_login() {
        while [ "$(getprop sys.boot_completed)" != "1" ]; do
            sleep 1
        done
        local test_file="/sdcard/Android/.PERMISSION_TEST"
        true >"$test_file"
        while [ ! -f "$test_file" ]; do
            true >"$test_file"
            sleep 1
        done
        rm -f "$test_file"
    }
fi

on_remove() {
    wait_until_login

    # Preserve user configurations across uninstalls/reinstalls
    mkdir -p /sdcard/.uperf_backup 2>/dev/null
    [ -f "$USER_PATH/perapp_powermode.txt" ] && cp -af "$USER_PATH/perapp_powermode.txt" /sdcard/.uperf_backup/
    [ -f "$USER_PATH/features.conf" ] && cp -af "$USER_PATH/features.conf" /sdcard/.uperf_backup/

    rm -rf "$USER_PATH"
    mkdir -p "$USER_PATH"
    [ -f /sdcard/.uperf_backup/perapp_powermode.txt ] && mv -f /sdcard/.uperf_backup/perapp_powermode.txt "$USER_PATH/"
    [ -f /sdcard/.uperf_backup/features.conf ] && mv -f /sdcard/.uperf_backup/features.conf "$USER_PATH/"
    rm -rf /sdcard/.uperf_backup 2>/dev/null

    rm -f /data/powercfg*
}

# do not block boot
(on_remove &)
