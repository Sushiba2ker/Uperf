#!/system/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
# Enhanced by Sushiba
#

MODDIR=${0%/*}

# Clean any stale temporary flags
rm -f "$MODDIR/flag/need_recuser" 2>/dev/null

# Early ZRAM ZSTD initialization (before swapon)
if [ -f /sys/block/zram0/comp_algorithm ]; then
    grep -q "zstd" /sys/block/zram0/comp_algorithm && echo zstd > /sys/block/zram0/comp_algorithm 2>/dev/null
fi
