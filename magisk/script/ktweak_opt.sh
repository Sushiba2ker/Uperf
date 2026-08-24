#!/system/bin/sh
#
# Hardware I/O, VM, Kernel & Network Optimization Engine
# Enhanced with Frosty Deep Kernel & Memory Architecture
# Author: Sushiba
#

# 1. Flash Storage Queue Optimizations (UFS / NVMe / eMMC)
for dev in /sys/block/*; do
    [ -d "$dev/queue" ] || continue
    dname="$(basename "$dev")"
    case "$dname" in ram*|loop*|zram*) continue ;; esac

    chmod 644 "$dev/queue/read_ahead_kb" 2>/dev/null && echo 128 > "$dev/queue/read_ahead_kb" 2>/dev/null
    chmod 644 "$dev/queue/nr_requests" 2>/dev/null && echo 64 > "$dev/queue/nr_requests" 2>/dev/null
    chmod 644 "$dev/queue/iostats" 2>/dev/null && echo 0 > "$dev/queue/iostats" 2>/dev/null
    chmod 644 "$dev/queue/add_random" 2>/dev/null && echo 0 > "$dev/queue/add_random" 2>/dev/null
done

# 2. Virtual Memory & Dirty Page Optimization
echo 5 > /proc/sys/vm/dirty_background_ratio 2>/dev/null
echo 20 > /proc/sys/vm/dirty_ratio 2>/dev/null
echo 500 > /proc/sys/vm/dirty_expire_centisecs 2>/dev/null
echo 500 > /proc/sys/vm/dirty_writeback_centisecs 2>/dev/null
echo 15 > /proc/sys/vm/stat_interval 2>/dev/null
echo 80 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
echo 0 > /proc/sys/vm/page-cluster 2>/dev/null
echo 1 > /proc/sys/vm/overcommit_memory 2>/dev/null
echo 0 > /proc/sys/vm/oom_dump_tasks 2>/dev/null

# Zero out watermark boost to eliminate micro-stutters during heavy memory burst
echo 0 > /proc/sys/vm/watermark_boost_factor 2>/dev/null
echo 100 > /proc/sys/vm/watermark_scale_factor 2>/dev/null

# Dynamic extra_free_kbytes tuning based on total physical memory
if [ -f /proc/sys/vm/extra_free_kbytes ]; then
    total_mem_kb=$(awk '/MemTotal/{print $2}' /proc/meminfo 2>/dev/null)
    if [ "${total_mem_kb:-0}" -ge 11534336 ]; then
        echo 24576 > /proc/sys/vm/extra_free_kbytes 2>/dev/null
    elif [ "${total_mem_kb:-0}" -ge 7340032 ]; then
        echo 16384 > /proc/sys/vm/extra_free_kbytes 2>/dev/null
    elif [ "${total_mem_kb:-0}" -ge 3145728 ]; then
        echo 12288 > /proc/sys/vm/extra_free_kbytes 2>/dev/null
    else
        echo 8192 > /proc/sys/vm/extra_free_kbytes 2>/dev/null
    fi
fi

# 3. ZRAM Parallel Stream Scaling
if [ -d /sys/block/zram0 ]; then
    streams=$(nproc 2>/dev/null || echo 8)
    echo "$streams" > /sys/block/zram0/max_comp_streams 2>/dev/null
fi

# 4. Kernel Jitter, Scheduler & Debug Suppression
echo 0 > /proc/sys/kernel/sched_schedstats 2>/dev/null
echo 0 > /proc/sys/kernel/sched_tunable_scaling 2>/dev/null
echo 0 > /proc/sys/kernel/sched_min_task_util_for_colocation 2>/dev/null
echo 2 > /proc/sys/kernel/perf_cpu_time_max_percent 2>/dev/null
echo 0 > /proc/sys/kernel/nmi_watchdog 2>/dev/null
echo 0 > /proc/sys/kernel/timer_migration 2>/dev/null

echo "off" > /proc/sys/kernel/printk_devkmsg 2>/dev/null
echo "0 0 0 0" > /proc/sys/kernel/printk 2>/dev/null
echo 1 > /proc/sys/kernel/printk_ratelimit 2>/dev/null
echo 1 > /proc/sys/kernel/printk_ratelimit_burst 2>/dev/null

echo 262144 > /proc/sys/fs/inotify/max_user_watches 2>/dev/null
echo 512 > /proc/sys/fs/inotify/max_user_instances 2>/dev/null

# 5. Suppress Dynamic Hardware Kernel Debug Masks
for pattern in debug_mask log_level debug_level enable_event_log; do
    for dpath in $(find /sys/ -maxdepth 4 -type f -name "$pattern" 2>/dev/null | head -25); do
        chmod +w "$dpath" 2>/dev/null
        echo 0 > "$dpath" 2>/dev/null
    done
done

# 6. Disable Intrusive OEM / Vendor Background Reclaim Daemon Loops
for vnode in \
    /sys/module/process_reclaim/parameters/enable_process_reclaim \
    /sys/kernel/mi_reclaim/enable \
    /sys/kernel/mi_reclaim/greclaim_enable \
    /sys/kernel/low_free/low_free_enable \
    /sys/module/memplus_core/parameters/memory_plus_enabled \
    /proc/sys/vm/memory_plus \
    /sys/module/perfmgr/parameters/perfmgr_enable \
    /sys/module/opchain/parameters/opchain_enable; do
    [ -f "$vnode" ] && echo 0 > "$vnode" 2>/dev/null
done

# 7. Next-Gen Network Protocol & TCP Stack Tuning
if [ -f /proc/sys/net/ipv4/tcp_congestion_control ] && [ -f /proc/sys/net/ipv4/tcp_available_congestion_control ]; then
    avail_cc=$(cat /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null)
    for algo in bbr3 bbr2 bbrplus bbr westwood cubic; do
        case "$avail_cc" in
            *"$algo"*)
                echo "$algo" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
                break
                ;;
        esac
    done
fi

echo 3 > /proc/sys/net/ipv4/tcp_fastopen 2>/dev/null
echo 0 > /proc/sys/net/ipv4/tcp_slow_start_after_idle 2>/dev/null
echo 600 > /proc/sys/net/ipv4/tcp_keepalive_time 2>/dev/null
echo 20 > /proc/sys/net/ipv4/tcp_keepalive_intvl 2>/dev/null
echo 5 > /proc/sys/net/ipv4/tcp_keepalive_probes 2>/dev/null
