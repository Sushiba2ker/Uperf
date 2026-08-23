#!/system/bin/sh
#
# Battery & Modem Thermal Guard Daemon for Pixel 8 Pro (Tensor G3)
# Author: Sushiba
#

BAT_TEMP_NODE="/sys/class/power_supply/battery/temp"
BAT_STATUS_NODE="/sys/class/power_supply/battery/status"
BAT_CHG_SPEED="/sys/class/power_supply/battery/charging_speed"
GPU_MAX_NODE="/sys/devices/platform/1f000000.mali/scaling_max_freq"
CUR_MODE_FILE="/sdcard/Android/yc/uperf/cur_powermode.txt"

last_mode=""

while true; do
    # 1. Battery Charging Thermal Guard
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

    # 2. Sync GPU Clamp with Active Mode
    if [ -f "$CUR_MODE_FILE" ] && [ -f "$GPU_MAX_NODE" ]; then
        cur_mode=$(cat "$CUR_MODE_FILE" 2>/dev/null | tr -d ' \n\r')
        if [ "$cur_mode" != "$last_mode" ]; then
            case "$cur_mode" in
                "powersave") chmod 644 $GPU_MAX_NODE 2>/dev/null; echo "580000" > $GPU_MAX_NODE 2>/dev/null ;;
                "balance")   chmod 644 $GPU_MAX_NODE 2>/dev/null; echo "649000" > $GPU_MAX_NODE 2>/dev/null ;;
                "auto")      chmod 644 $GPU_MAX_NODE 2>/dev/null; echo "723000" > $GPU_MAX_NODE 2>/dev/null ;;
                "performance"|"fast") chmod 644 $GPU_MAX_NODE 2>/dev/null; echo "890000" > $GPU_MAX_NODE 2>/dev/null ;;
            esac
            last_mode="$cur_mode"
        fi
    fi

    sleep 10
done
