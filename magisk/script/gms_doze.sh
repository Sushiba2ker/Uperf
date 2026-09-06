#!/system/bin/sh
#
# Smart GMS Doze, Deep Sleep & F2FS Storage Maintenance Engine
# Enhanced with Frosty Deep Doze & Memory Compaction
# Author: Sushiba
#

BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/pathinfo.sh"
. "$BASEDIR/libcommon.sh"
feature_enabled gms_doze || exit 0

PID_FILE="$RUNTIME_PATH/gms_doze.pid"
acquire_daemon_lock gms_doze || exit 0

cleanup_f2fs() {
    for f2fs_node in /sys/fs/f2fs/*/gc_urgent; do
        [ -f "$f2fs_node" ] && echo 0 > "$f2fs_node" 2>/dev/null
    done
}

is_screen_off() {
    local pwr_dump
    pwr_dump="$(dumpsys power 2>/dev/null)"
    [ -z "$pwr_dump" ] && return 1

    if echo "$pwr_dump" | grep -qE "mWakefulness=(Asleep|Dozing|Dreaming)"; then
        return 0
    fi
    if echo "$pwr_dump" | grep -q "mHoldingDisplaySuspendBlocker=false"; then
        return 0
    fi
    return 1
}

(
    was_screen_off=false

    cleanup() {
        cleanup_f2fs
        if [ "$was_screen_off" = "true" ]; then
            dumpsys deviceidle unforce >/dev/null 2>&1
        fi
        rm -f "$PID_FILE"
    }
    trap cleanup EXIT
    trap 'exit 0' INT TERM

    # Wait until system is fully booted and user storage is unlocked.
    until [ "$(getprop sys.boot_completed)" = "1" ] && [ -d /sdcard/Android ]; do
        sleep 5
    done
    sleep 10

    # Whitelist critical communication and push services so notifications remain available.
    dumpsys deviceidle whitelist +com.google.android.gms 2>/dev/null
    dumpsys deviceidle whitelist +com.zing.zalo 2>/dev/null
    dumpsys deviceidle whitelist +com.facebook.orca 2>/dev/null
    dumpsys deviceidle whitelist +org.telegram.messenger 2>/dev/null
    dumpsys deviceidle whitelist +com.whatsapp 2>/dev/null
    dumpsys deviceidle whitelist +com.google.android.apps.messaging 2>/dev/null

    # Background sleep and storage maintenance loop (180s interval).
    while feature_enabled gms_doze; do
        sleep 180
        feature_enabled gms_doze || break

        if is_screen_off; then
            # Screen is OFF: allow F2FS maintenance GC during idle sleep.
            for f2fs_node in /sys/fs/f2fs/*/gc_urgent; do
                [ -f "$f2fs_node" ] && echo 1 > "$f2fs_node" 2>/dev/null
            done

            # Memory compaction and page cache cleanup.
            sync
            echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
            compact_memory_pools

            # Step deep doze force-idle.
            if ! dumpsys deviceidle force-idle deep 2>/dev/null; then
                for i in 1 2 3 4; do cmd deviceidle step deep 2>/dev/null; done
            fi

            was_screen_off=true
        else
            # Screen is ON: disable GC to avoid frame drops and micro-stutter.
            cleanup_f2fs

            if [ "$was_screen_off" = "true" ]; then
                dumpsys deviceidle unforce 2>/dev/null
                was_screen_off=false
            fi
        fi
    done
) &

printf '%s\n' "$!" > "$PID_FILE"
