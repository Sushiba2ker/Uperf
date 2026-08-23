#!/system/bin/sh
#
# Battery Thermal Charging Guard Daemon for Pixel 8 Pro (Tensor G3)
# Author: Sushiba
#

BAT_TEMP_NODE="/sys/class/power_supply/battery/temp"
BAT_STATUS_NODE="/sys/class/power_supply/battery/status"
BAT_CHG_SPEED="/sys/class/power_supply/battery/charging_speed"

while true; do
    # Battery Charging Thermal Protection
    if [ -f "$BAT_TEMP_NODE" ] && [ -f "$BAT_STATUS_NODE" ]; then
        bat_temp=$(cat "$BAT_TEMP_NODE" 2>/dev/null)
        bat_status=$(cat "$BAT_STATUS_NODE" 2>/dev/null)

        if [ "$bat_status" = "Charging" ]; then
            # If battery temp > 40.5C (405)
            if [ -n "$bat_temp" ] && [ "$bat_temp" -gt 405 ] 2>/dev/null; then
                if [ -f "$BAT_CHG_SPEED" ]; then
                    echo "1" > "$BAT_CHG_SPEED" 2>/dev/null
                fi
            # If cooled down below 37.5C (375)
            elif [ -n "$bat_temp" ] && [ "$bat_temp" -lt 375 ] 2>/dev/null; then
                if [ -f "$BAT_CHG_SPEED" ]; then
                    echo "0" > "$BAT_CHG_SPEED" 2>/dev/null
                fi
            fi
        fi
    fi

    sleep 10
done
