#!/system/bin/sh
#
# Smart RAM Cleaner & Memory Compaction Tool
# Ported & Optimized from Frosty for Uperf
# Author: Sushiba
#

mem_before=$(awk '/MemAvailable/{print $2}' /proc/meminfo 2>/dev/null)

sync
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null

if [ -f /proc/sys/vm/compact_memory ]; then
    echo 1 > /proc/sys/vm/compact_memory 2>/dev/null
fi

if [ -f /sys/block/zram0/compact ]; then
    echo 1 > /sys/block/zram0/compact 2>/dev/null
fi

am kill-all 2>/dev/null

mem_after=$(awk '/MemAvailable/{print $2}' /proc/meminfo 2>/dev/null)
freed_mb=$(( (${mem_after:-0} - ${mem_before:-0}) / 1024 ))
[ "$freed_mb" -lt 0 ] && freed_mb=0

echo "{\"status\":\"ok\",\"freed_mb\":$freed_mb,\"available_mb\":$(( ${mem_after:-0} / 1024 ))}"
