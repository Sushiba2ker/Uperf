#!/system/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
# Enhanced for Google Tensor G3 by Sushiba
#

BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh

GPU_MAX_NODE="/sys/devices/platform/1f000000.mali/scaling_max_freq"

apply_gpu_clamp() {
    local mode="$1"
    if [ -f "$GPU_MAX_NODE" ]; then
        case "$mode" in
            "powersave") chmod 644 $GPU_MAX_NODE 2>/dev/null; echo "580000" > $GPU_MAX_NODE 2>/dev/null ;;
            "balance")   chmod 644 $GPU_MAX_NODE 2>/dev/null; echo "649000" > $GPU_MAX_NODE 2>/dev/null ;;
            "auto")      chmod 644 $GPU_MAX_NODE 2>/dev/null; echo "723000" > $GPU_MAX_NODE 2>/dev/null ;;
            "performance"|"fast") chmod 644 $GPU_MAX_NODE 2>/dev/null; echo "890000" > $GPU_MAX_NODE 2>/dev/null ;;
        esac
    fi
}

action="$1"
case "$1" in
"powersave" | "balance" | "performance" | "fast" | "auto")
    echo "$1" >"$USER_PATH/cur_powermode.txt"
    apply_gpu_clamp "$1"
    ;;
"pedestal")
    echo "performance" >"$USER_PATH/cur_powermode.txt"
    apply_gpu_clamp "performance"
    ;;
"init")
    echo "balance" >"$USER_PATH/cur_powermode.txt"
    apply_gpu_clamp "balance"
    ;;
*)
    echo "Failed to apply unknown action '$1'."
    ;;
esac
