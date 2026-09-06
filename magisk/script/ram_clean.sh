#!/system/bin/sh
#
# Smart RAM Cleaner & Memory Compaction Tool
# Ported & Optimized from Frosty for Uperf
# Author: Sushiba
#
BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/pathinfo.sh"
. "$BASEDIR/libcommon.sh"
if ! feature_enabled ram_clean; then
    printf '{"status":"disabled","feature":"ram_clean"}\n'
    exit 0
fi

mem_before=$(awk '/MemAvailable/{print $2}' /proc/meminfo 2>/dev/null)

sync
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null

compact_memory_pools

am kill-all 2>/dev/null

mem_after=$(awk '/MemAvailable/{print $2}' /proc/meminfo 2>/dev/null)
freed_mb=$(( (${mem_after:-0} - ${mem_before:-0}) / 1024 ))
[ "$freed_mb" -lt 0 ] && freed_mb=0

echo "{\"status\":\"ok\",\"freed_mb\":$freed_mb,\"available_mb\":$(( ${mem_after:-0} / 1024 ))}"
