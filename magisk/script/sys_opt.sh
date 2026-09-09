#!/system/bin/sh
#
# Advanced Framework Tracing, Logging & Telemetry Killer
# Ported & Optimized from Frosty for Uperf
# Author: Sushiba
#
BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/pathinfo.sh"
. "$BASEDIR/libcommon.sh"
feature_enabled system_tweaks || exit 0

# 1. Kill Kernel Tracing & Diagnostic Subsystems
if [ -d /sys/kernel/tracing ]; then
    echo 0 > /sys/kernel/tracing/tracing_on 2>/dev/null
    echo > /sys/kernel/tracing/trace 2>/dev/null
fi
if [ -d /sys/kernel/debug/tracing ]; then
    echo 0 > /sys/kernel/debug/tracing/tracing_on 2>/dev/null
    echo > /sys/kernel/debug/tracing/trace 2>/dev/null
fi

stop traced 2>/dev/null
stop traced_probes 2>/dev/null
stop cnss_diag 2>/dev/null
# Retain statsd: stopping it breaks AIDL stats service used by core system
# components (system_server, gpuservice, mediametrics), triggering IPC retry loops
# that cause task freeze failures and abort kernel suspend (-EBUSY) on Android 14+.
stop aplogd 2>/dev/null

dmesg -n 1 2>/dev/null
logcat -G 64k 2>/dev/null

# 2. Suppress Framework Performance Logging & Jank Monitor Frame Tracing
cmd activity idle-maintenance >/dev/null 2>&1
cmd autofill set log_level off >/dev/null 2>&1
cmd display set-user-preferred-display-mode off >/dev/null 2>&1
cmd window logging disable-all >/dev/null 2>&1
cmd wifi set-verbose-logging disabled >/dev/null 2>&1

device_config put interaction_jank_monitor enabled false >/dev/null 2>&1
device_config put interaction_jank_monitor sampling_interval 0 >/dev/null 2>&1
device_config put activity_manager disable_app_profiler_pss_profiling true >/dev/null 2>&1
device_config put activity_manager activity_start_pss_defer 300000 >/dev/null 2>&1

# 3. Android Runtime Performance Enhancements
device_config put activity_manager use_compaction true >/dev/null 2>&1
device_config put activity_manager_native_boot use_compaction true >/dev/null 2>&1
device_config put activity_manager_native_boot use_freezer true >/dev/null 2>&1
device_config put alarm_manager save_battery_on_idle true >/dev/null 2>&1
device_config put runtime_native usap_pool_enabled true >/dev/null 2>&1

# 4. Google Telemetry, Analytics & Background Polling Suppression
settings put global gmscorestat_enabled 0 >/dev/null 2>&1
settings put global play_store_panel_logging_enabled 0 >/dev/null 2>&1
settings put global clearcut_enabled 0 >/dev/null 2>&1
settings put global clearcut_events 0 >/dev/null 2>&1
settings put global clearcut_gcm 0 >/dev/null 2>&1
settings put global phenotype__debug_bypass_phenotype 1 >/dev/null 2>&1
settings put global phenotype_boot_count 99 >/dev/null 2>&1
settings put global phenotype_flags "disable_log_upload=1,disable_log_for_missing_debug_id=1" >/dev/null 2>&1
settings put global ga_collection_enabled 0 >/dev/null 2>&1
settings put global analytics_enabled 0 >/dev/null 2>&1
settings put global uploading_enabled 0 >/dev/null 2>&1
settings put global bug_report_in_power_menu 0 >/dev/null 2>&1
settings put global usage_stats_enabled 0 >/dev/null 2>&1
settings put global usagestats_collection_enabled 0 >/dev/null 2>&1
settings put global network_watchlist_enabled 0 >/dev/null 2>&1
settings put global limit_ad_tracking 1 >/dev/null 2>&1
settings put global tron_enabled 0 >/dev/null 2>&1
settings put global gms_checkin_timeout_min 120 >/dev/null 2>&1

# Binder Call Sampling & Battery Stats Frequency Optimization
settings put global binder_calls_stats \
    "detailed_tracking=false,sampling_interval=10000,max_call_stats=100" >/dev/null 2>&1

settings put global battery_stats_constants \
    "track_cpu_active_cluster_time=false,kernel_energy_path=null" >/dev/null 2>&1

# Network & Wi-Fi Background Scanning Throttle
settings put global netstats_enabled 0 >/dev/null 2>&1
settings put global netstats_poll_interval 60000 >/dev/null 2>&1
settings put global netstats_persist_threshold 2097152 >/dev/null 2>&1
settings put global netstats_global_alert_bytes 2097152 >/dev/null 2>&1
settings put global wifi_scan_throttle_enabled 1 >/dev/null 2>&1
settings put global wifi_scan_always_enabled 0 >/dev/null 2>&1

# 5. Disable Intrusive Dropbox Logging Tags
DROPBOX_TAGS="
dumpsys:procstats
dumpsys:usagestats
procstats
usagestats
data_app_wtf
keymaster
system_server_wtf
system_app_strictmode
system_app_wtf
system_server_strictmode
data_app_strictmode
netstats
data_app_anr
data_app_crash
system_server_anr
system_server_watchdog
system_server_crash
system_server_native_crash
system_server_lowmem
system_app_crash
system_app_anr
storage_trim
SYSTEM_AUDIT
SYSTEM_BOOT
SYSTEM_LAST_KMSG
system_app_native_crash
SYSTEM_TOMBSTONE
SYSTEM_TOMBSTONE_PROTO
data_app_native_crash
SYSTEM_RESTART
"

for tag in $DROPBOX_TAGS; do
    [ -n "$tag" ] && settings put global "dropbox:$tag" disabled >/dev/null 2>&1
done
