#!/system/bin/sh
#
# Battery Thermal Charging Guard Daemon for Pixel 8 Pro (Tensor G3)
# Author: Sushiba
#

BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/pathinfo.sh"
. "$BASEDIR/libcommon.sh"
feature_enabled thermal_guard || exit 0

PID_FILE="$RUNTIME_PATH/thermal_guard.pid"
acquire_daemon_lock thermal_guard || exit 0

BAT_TEMP_NODE="/sys/class/power_supply/battery/temp"
BAT_STATUS_NODE="/sys/class/power_supply/battery/status"
BAT_CHG_SPEED="/sys/class/power_supply/battery/charging_speed"

# Preserve the driver's default value (e.g. -1) and restore it after cooling,
# instead of hardcoding "0" whose semantics may differ per driver build.
CHG_SPEED_REDUCED=1
CHG_SPEED_NORMAL="$(cat "$BAT_CHG_SPEED" 2>/dev/null)"
[ -n "$CHG_SPEED_NORMAL" ] || CHG_SPEED_NORMAL="-1"
LAST_WRITTEN=""
THROTTLE_TICKS=0
MAX_THROTTLE_TICKS=120 # 20 minutes timeout fallback (120 * 10s)
cleanup() {
    if [ -f "$BAT_CHG_SPEED" ] && [ -n "$LAST_WRITTEN" ]; then
        echo "$CHG_SPEED_NORMAL" > "$BAT_CHG_SPEED" 2>/dev/null
    fi
    rm -f "$PID_FILE"
}
trap cleanup EXIT
trap 'exit 0' INT TERM

while feature_enabled thermal_guard; do
    if [ -f "$BAT_TEMP_NODE" ] && [ -f "$BAT_STATUS_NODE" ]; then
        bat_temp=$(cat "$BAT_TEMP_NODE" 2>/dev/null)
        bat_status=$(cat "$BAT_STATUS_NODE" 2>/dev/null)

        if [ "$bat_status" = "Charging" ]; then
            # If battery temp > 40.5C (405): reduce charging current (write once).
            if [ -n "$bat_temp" ] && [ "$bat_temp" -gt 405 ] 2>/dev/null; then
                if [ -f "$BAT_CHG_SPEED" ] && [ "$LAST_WRITTEN" != "$CHG_SPEED_REDUCED" ]; then
                    echo "$CHG_SPEED_REDUCED" > "$BAT_CHG_SPEED" 2>/dev/null && LAST_WRITTEN="$CHG_SPEED_REDUCED"
                    THROTTLE_TICKS=0
                fi
                if [ "$LAST_WRITTEN" = "$CHG_SPEED_REDUCED" ]; then
                    THROTTLE_TICKS=$((THROTTLE_TICKS + 1))
                    # Auto timeout fallback (20 min) to prevent latch trap
                    if [ "$THROTTLE_TICKS" -ge "$MAX_THROTTLE_TICKS" ]; then
                        echo "$CHG_SPEED_NORMAL" > "$BAT_CHG_SPEED" 2>/dev/null && LAST_WRITTEN="$CHG_SPEED_NORMAL"
                        THROTTLE_TICKS=0
                    fi
                fi
            # If cooled down below 37.5C (375): restore the driver's original value.
            elif [ -n "$bat_temp" ] && [ "$bat_temp" -lt 375 ] 2>/dev/null; then
                if [ -f "$BAT_CHG_SPEED" ] && [ "$LAST_WRITTEN" != "$CHG_SPEED_NORMAL" ]; then
                    echo "$CHG_SPEED_NORMAL" > "$BAT_CHG_SPEED" 2>/dev/null && LAST_WRITTEN="$CHG_SPEED_NORMAL"
                    THROTTLE_TICKS=0
                fi
            fi
        else
            # When unplugged or not charging: immediately release any throttled latch
            if [ -f "$BAT_CHG_SPEED" ] && [ -n "$LAST_WRITTEN" ] && [ "$LAST_WRITTEN" != "$CHG_SPEED_NORMAL" ]; then
                echo "$CHG_SPEED_NORMAL" > "$BAT_CHG_SPEED" 2>/dev/null
                LAST_WRITTEN="$CHG_SPEED_NORMAL"
                THROTTLE_TICKS=0
            fi
        fi
    fi

    sleep 10
done
