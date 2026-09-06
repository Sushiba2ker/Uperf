#!/vendor/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
# Enhanced for Google Tensor G3 by Sushiba
#

# powercfg wrapper for com.omarea.vtools / Scene Tool / terminal callers
if [ -f "/data/adb/modules/uperf/script/powercfg_main.sh" ]; then
    sh "/data/adb/modules/uperf/script/powercfg_main.sh" "$1"
elif [ -f "/data/uperf/script/powercfg_main.sh" ]; then
    sh "/data/uperf/script/powercfg_main.sh" "$1"
fi
