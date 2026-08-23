#!/system/bin/sh
#
# Battery Thermal Charging Guard Daemon for Pixel 8 Pro (Tensor G3)
# Author: Sushiba
#

BAT_TEMP_NODE="/sys/class/power_supply/battery/temp"
BAT_STATUS_NODE="/sys/class/power_supply/battery/status"
BAT_CHG_SPEED="/sys/class/power_supply/battery/charging_speed"

# Preserve the driver's default value (e.g. -1) and restore it after cooling,
# instead of hardcoding "0" whose semantics may differ per driver build.
CHG_SPEED_REDUCED=1
CHG_SPEED_NORMAL="$(cat "$BAT_CHG_SPEED" 2>/dev/null)"
[ -n "$CHG_SPEED_NORMAL" ] || CHG_SPEED_NORMAL="0"
LAST_WRITTEN=""

while true; do
    # Battery Charging Thermal Protection
    if [ -f "$BAT_TEMP_NODE" ] && [ -f "$BAT_STATUS_NODE" ]; then
        bat_temp=$(cat "$BAT_TEMP_NODE" 2>/dev/null)
        bat_status=$(cat "$BAT_STATUS_NODE" 2>/dev/null)

        if [ "$bat_status" = "Charging" ]; then
            # If battery temp > 40.5C (405): reduce charging current (write once)
            if [ -n "$bat_temp" ] && [ "$bat_temp" -gt 405 ] 2>/dev/null; then
                if [ -f "$BAT_CHG_SPEED" ] && [ "$LAST_WRITTEN" != "$CHG_SPEED_REDUCED" ]; then
                    echo "$CHG_SPEED_REDUCED" > "$BAT_CHG_SPEED" 2>/dev/null && LAST_WRITTEN="$CHG_SPEED_REDUCED"
                fi
            # If cooled down below 37.5C (375): restore the driver's original value
            elif [ -n "$bat_temp" ] && [ "$bat_temp" -lt 375 ] 2>/dev/null; then
                if [ -f "$BAT_CHG_SPEED" ] && [ "$LAST_WRITTEN" != "$CHG_SPEED_NORMAL" ]; then
                    echo "$CHG_SPEED_NORMAL" > "$BAT_CHG_SPEED" 2>/dev/null && LAST_WRITTEN="$CHG_SPEED_NORMAL"
                fi
            fi
        fi
    fi

    sleep 10
done
