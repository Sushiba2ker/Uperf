#!/system/bin/sh
#
# Uperf Sushiba Core Hardware Profile Dispatcher
# Google Tensor G3 (Zuma)
# Author: Sushiba
#

BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh

GPU_MAX_NODE="/sys/devices/platform/1f000000.mali/scaling_max_freq"
MIF_MAX_NODE="/sys/class/devfreq/17000010.devfreq_mif/max_freq"
DSU_MAX_NODE="/sys/class/devfreq/17000090.devfreq_dsu/max_freq"

apply_hardware_profile() {
    local mode="$1"

    # 1. Update active mode flag atomically
    echo "$mode" > "$USER_PATH/cur_powermode.txt"
    echo "$mode" > "/data/cur_powermode.txt" 2>/dev/null

    # 2. Hardware DVFS Node Clamps
    case "$mode" in
        "powersave")
            # GPU 580MHz, RAM 2288MHz, DSU 1328MHz (Max battery & cool)
            [ -f "$GPU_MAX_NODE" ] && { chmod 644 "$GPU_MAX_NODE" 2>/dev/null; echo "580000" > "$GPU_MAX_NODE" 2>/dev/null; }
            [ -f "$MIF_MAX_NODE" ] && { chmod 644 "$MIF_MAX_NODE" 2>/dev/null; echo "2288000" > "$MIF_MAX_NODE" 2>/dev/null; }
            [ -f "$DSU_MAX_NODE" ] && { chmod 644 "$DSU_MAX_NODE" 2>/dev/null; echo "1328000" > "$DSU_MAX_NODE" 2>/dev/null; }
            ;;
        "balance")
            # GPU 649MHz, RAM 2730MHz, DSU 1548MHz (Balanced)
            [ -f "$GPU_MAX_NODE" ] && { chmod 644 "$GPU_MAX_NODE" 2>/dev/null; echo "649000" > "$GPU_MAX_NODE" 2>/dev/null; }
            [ -f "$MIF_MAX_NODE" ] && { chmod 644 "$MIF_MAX_NODE" 2>/dev/null; echo "2730000" > "$MIF_MAX_NODE" 2>/dev/null; }
            [ -f "$DSU_MAX_NODE" ] && { chmod 644 "$DSU_MAX_NODE" 2>/dev/null; echo "1548000" > "$DSU_MAX_NODE" 2>/dev/null; }
            ;;
        "auto")
            # GPU 723MHz, RAM 3172MHz, DSU 1704MHz (Adaptive)
            [ -f "$GPU_MAX_NODE" ] && { chmod 644 "$GPU_MAX_NODE" 2>/dev/null; echo "723000" > "$GPU_MAX_NODE" 2>/dev/null; }
            [ -f "$MIF_MAX_NODE" ] && { chmod 644 "$MIF_MAX_NODE" 2>/dev/null; echo "3172000" > "$MIF_MAX_NODE" 2>/dev/null; }
            [ -f "$DSU_MAX_NODE" ] && { chmod 644 "$DSU_MAX_NODE" 2>/dev/null; echo "1704000" > "$DSU_MAX_NODE" 2>/dev/null; }
            ;;
        "performance"|"fast"|"pedestal")
            # GPU 890MHz, RAM 3744MHz, DSU 1800MHz (Full throttle)
            [ -f "$GPU_MAX_NODE" ] && { chmod 644 "$GPU_MAX_NODE" 2>/dev/null; echo "890000" > "$GPU_MAX_NODE" 2>/dev/null; }
            [ -f "$MIF_MAX_NODE" ] && { chmod 644 "$MIF_MAX_NODE" 2>/dev/null; echo "3744000" > "$MIF_MAX_NODE" 2>/dev/null; }
            [ -f "$DSU_MAX_NODE" ] && { chmod 644 "$DSU_MAX_NODE" 2>/dev/null; echo "1800000" > "$DSU_MAX_NODE" 2>/dev/null; }
            ;;
    esac
}

action="$1"
case "$1" in
    "powersave" | "balance" | "performance" | "fast" | "auto")
        apply_hardware_profile "$1"
        ;;
    "pedestal")
        apply_hardware_profile "performance"
        ;;
    "init")
        apply_hardware_profile "balance"
        ;;
    *)
        echo "Failed to apply unknown action '$1'."
        ;;
esac
