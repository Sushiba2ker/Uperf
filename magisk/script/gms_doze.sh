#!/system/bin/sh
#
# Smart GMS Doze & Deep Sleep Engine
# Derived from Universal GMS Doze & tailored for Uperf Sushiba
# Author: Sushiba
#

(
    # Wait until system is fully booted and user storage is unlocked
    until [ "$(getprop sys.boot_completed)" = "1" ] && [ -d /sdcard/Android ]; do
        sleep 5
    done
    sleep 10

    # Whitelist critical communication and push services so notifications NEVER fail
    dumpsys deviceidle whitelist +com.zing.zalo 2>/dev/null
    dumpsys deviceidle whitelist +com.facebook.orca 2>/dev/null
    dumpsys deviceidle whitelist +org.telegram.messenger 2>/dev/null
    dumpsys deviceidle whitelist +com.whatsapp 2>/dev/null
    dumpsys deviceidle whitelist +com.google.android.apps.messaging 2>/dev/null

    # Put GMS into battery optimization
    GMS="com.google.android.gms"
    dumpsys deviceidle whitelist -$GMS 2>/dev/null
) &
