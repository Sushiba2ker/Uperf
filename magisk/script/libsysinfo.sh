#!/system/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
# Enhanced for Google Tensor G3 by Sushiba
#

# $1:policy_num
get_maxfreq() {
    cat /sys/devices/system/cpu/cpufreq/policy"$1"/cpuinfo_max_freq 2>/dev/null || echo 0
}

# $1:policy_num
get_minfreq() {
    cat /sys/devices/system/cpu/cpufreq/policy"$1"/cpuinfo_min_freq 2>/dev/null || echo 0
}

# $1:board_name
get_config_name() {
    case "$1" in
    "husky" | "zuma" | "shiba" | "akita" | "gs301") echo "gs301" ;;
    *) echo "unsupported" ;;
    esac
}
