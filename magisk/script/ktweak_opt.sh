#!/system/bin/sh
#
# KTweak-derived I/O & Memory Optimization Engine
# Integrated into Uperf Sushiba
#

# 1. Block Device / Flash Storage Queue Optimizations (UFS 3.1)
for queue in /sys/block/*/queue; do
    [ -d "$queue" ] || continue
    chmod 644 "$queue/read_ahead_kb" 2>/dev/null && echo 128 > "$queue/read_ahead_kb" 2>/dev/null
    chmod 644 "$queue/nr_requests" 2>/dev/null && echo 64 > "$queue/nr_requests" 2>/dev/null
    chmod 644 "$queue/iostats" 2>/dev/null && echo 0 > "$queue/iostats" 2>/dev/null
    chmod 644 "$queue/add_random" 2>/dev/null && echo 0 > "$queue/add_random" 2>/dev/null
done

# 2. Virtual Memory & Dirty Page Optimization
echo 10 > /proc/sys/vm/dirty_background_ratio 2>/dev/null
echo 30 > /proc/sys/vm/dirty_ratio 2>/dev/null
echo 10 > /proc/sys/vm/stat_interval 2>/dev/null
echo 100 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
echo 0 > /proc/sys/vm/page-cluster 2>/dev/null

# 3. Kernel Latency & Jitter Suppression
echo 0 > /proc/sys/kernel/sched_schedstats 2>/dev/null
echo "off" > /proc/sys/kernel/printk_devkmsg 2>/dev/null
echo 5000000 > /proc/sys/kernel/sched_migration_cost_ns 2>/dev/null
echo 32 > /proc/sys/kernel/sched_nr_migrate 2>/dev/null
