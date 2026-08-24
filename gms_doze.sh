#!/system/bin/sh
#
# Smart GMS Doze, Deep Sleep & F2FS Storage Maintenance Engine
# Enhanced with Frosty Deep Doze & Memory Compaction
# Author: Sushiba
#

# Reset F2FS GC to normal mode upon exit/termination
cleanup_f2fs() {
    for f2fs_node in /sys/fs/f2fs/*/gc_urgent; do
        [ -f "$f2fs_node" ] && echo 0 > "$f2fs_node" 2>/dev/null
    done
}
trap cleanup_f2fs EXIT INT TERM

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
    # Wait until system is fully booted and user storage is unlocked
    until [ "$(getprop sys.boot_completed)" = "1" ] && [ -d /sdcard/Android ]; do
        sleep 5
    done
    sleep 10

    # Whitelist critical communication and push services so notifications NEVER fail
    dumpsys deviceidle whitelist +com.google.android.gms 2>/dev/null
    dumpsys deviceidle whitelist +com.zing.zalo 2>/dev/null
    dumpsys deviceidle whitelist +com.facebook.orca 2>/dev/null
    dumpsys deviceidle whitelist +org.telegram.messenger 2>/dev/null
    dumpsys deviceidle whitelist +com.whatsapp 2>/dev/null
    dumpsys deviceidle whitelist +com.google.android.apps.messaging 2>/dev/null

    was_screen_off=false

    # Background Sleep & Storage Maintenance Loop (180s interval)
    while true; do
        sleep 180

        if is_screen_off; then
            # 1. Screen is OFF: Allow F2FS maintenance GC during idle sleep
            for f2fs_node in /sys/fs/f2fs/*/gc_urgent; do
                [ -f "$f2fs_node" ] && echo 1 > "$f2fs_node" 2>/dev/null
            done

            # 2. Memory compaction & page cache cleanup
            sync
            echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
            [ -f /proc/sys/vm/compact_memory ] && echo 1 > /proc/sys/vm/compact_memory 2>/dev/null
            [ -f /sys/block/zram0/compact ] && echo 1 > /sys/block/zram0/compact 2>/dev/null

            # 3. Step deep doze force-idle
            if ! dumpsys deviceidle force-idle deep 2>/dev/null; then
                for i in 1 2 3 4; do cmd deviceidle step deep 2>/dev/null; done
            fi

            # 4. Enable JobScheduler flex-policy idle mode (Android 13+)
            cmd jobscheduler enable-flex-policy --option idle 2>/dev/null

            was_screen_off=true
        else
            # Screen is ON: strictly disable GC & reset flex policy to eliminate frame drops & micro-stutter
            for f2fs_node in /sys/fs/f2fs/*/gc_urgent; do
                [ -f "$f2fs_node" ] && echo 0 > "$f2fs_node" 2>/dev/null
            done

            if [ "$was_screen_off" = "true" ]; then
                cmd jobscheduler reset-flex-policy 2>/dev/null
                dumpsys deviceidle unforce 2>/dev/null
                was_screen_off=false
            fi
        fi
    done
) &
