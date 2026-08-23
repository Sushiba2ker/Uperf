#!/system/bin/sh
#
# Smart GMS Doze & Deep Sleep Engine with F2FS Background Storage Maintenance
# Google Tensor G3 (Pixel 8 Pro / Android 17)
# Author: Sushiba
#

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

    # F2FS Smart Garbage Collection background service
    while true; do
        sleep 120
        # Check if screen is off (display interactive = false)
        if dumpsys power | grep -q "mHoldingDisplaySuspendBlocker=false" 2>/dev/null; then
            for f2fs_node in /sys/fs/f2fs/*/gc_urgent; do
                [ -f "$f2fs_node" ] && echo 1 > "$f2fs_node" 2>/dev/null
            done
        else
            for f2fs_node in /sys/fs/f2fs/*/gc_urgent; do
                [ -f "$f2fs_node" ] && echo 0 > "$f2fs_node" 2>/dev/null
            done
        fi
    done
) &
