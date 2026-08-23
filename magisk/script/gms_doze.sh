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
    dumpsys deviceidle whitelist +com.google.android.gms 2>/dev/null
    dumpsys deviceidle whitelist +com.zing.zalo 2>/dev/null
    dumpsys deviceidle whitelist +com.facebook.orca 2>/dev/null
    dumpsys deviceidle whitelist +org.telegram.messenger 2>/dev/null
    dumpsys deviceidle whitelist +com.whatsapp 2>/dev/null
    dumpsys deviceidle whitelist +com.google.android.apps.messaging 2>/dev/null

    # Disable unnecessary background device administrators in GMS that keep CPU awake
    GMS="com.google.android.gms"
    GC1="auth.managed.admin.DeviceAdminReceiver"
    GC2="mdm.receivers.MdmDeviceAdminReceiver"

    if [ -d /data/user ]; then
        for U in $(ls /data/user 2>/dev/null); do
            pm disable --user "$U" "$GMS/$GMS.$GC1" 2>/dev/null
            pm disable --user "$U" "$GMS/$GMS.$GC2" 2>/dev/null
        done
    fi

    # Put GMS into battery optimization
    dumpsys deviceidle whitelist -$GMS 2>/dev/null
) &
