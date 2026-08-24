#!/system/bin/sh
#
# System Tracing, Telemetry, Framework Runtime & Battery Optimization Engine
# Ported & Enhanced from Frosty
# Author: Sushiba
#

# 1. Kernel Tracing & Diagnostic Logging Daemon Suppression
if [ -f /sys/kernel/tracing/tracing_on ]; then
    echo 0 > /sys/kernel/tracing/tracing_on 2>/dev/null
fi

for svc in traced traced_perf traced_probes cnss_diag vendor.cnss_diag tcpdump vendor.tcpdump aplogd; do
    pid=$(pidof "$svc" 2>/dev/null)
    [ -n "$pid" ] && kill -9 "$pid" 2>/dev/null
done

logcat -c 2>/dev/null
dmesg -c >/dev/null 2>&1
dmesg -n 1 2>/dev/null
logcat -G 64k 2>/dev/null

# 2. Android Framework Subsystem Tracing & Jank Monitor Overhead Suppression
cmd activity logging disable-text >/dev/null 2>&1
cmd autofill set log_level off >/dev/null 2>&1
cmd display ab-logging-disable >/dev/null 2>&1
cmd display dmd-logging-disable >/dev/null 2>&1
cmd display dwb-logging-disable >/dev/null 2>&1
cmd input_method tracing stop >/dev/null 2>&1
cmd statusbar tracing stop >/dev/null 2>&1
cmd window logging disable >/dev/null 2>&1
cmd window logging disable-text >/dev/null 2>&1
cmd window tracing size 0 >/dev/null 2>&1
cmd voiceinteraction set-debug-hotword-logging false 2>/dev/null
cmd wifi set-verbose-logging disabled -l 0 >/dev/null 2>&1

# Suppress Jank Monitor Tracing Overhead during UI rendering
device_config put interaction_jank_monitor enabled false >/dev/null 2>&1
device_config put interaction_jank_monitor trace_threshold_frame_time_millis -1 >/dev/null 2>&1
device_config put activity_manager disable_app_profiler_pss_profiling true >/dev/null 2>&1
device_config put activity_manager activity_start_pss_defer 300000 >/dev/null 2>&1

# 3. Android Framework Runtime Performance & Compaction
device_config put activity_manager use_compaction true >/dev/null 2>&1
device_config put activity_manager_native_boot use_freezer true >/dev/null 2>&1
device_config put alarm_manager save_battery_on_idle true >/dev/null 2>&1

sdk=$(getprop ro.build.version.sdk 2>/dev/null)
if [ "${sdk:-0}" -ge 30 ] 2>/dev/null; then
    content call --uri content://settings/config --method PUT_value \
        --arg runtime_native/usap_pool_enabled --extra value:s:true >/dev/null 2>&1
fi

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
    "sampling_interval=600000000,detailed_tracking=disable,enabled=false,upload_data=false" >/dev/null 2>&1

settings put global battery_stats_constants \
    "track_cpu_times_by_proc_state=false,track_cpu_active_cluster_time=false,read_binary_cpu_time=false,kernel_uid_readers_throttle_time=2000,external_stats_collection_rate_limit_ms=1200000,battery_level_collection_delay_ms=600000,procstate_change_collection_delay_ms=120000,max_history_files=1,max_history_buffer_kb=512,battery_charged_delay_ms=1800000,phone_on_external_stats_collection=false,reset_while_plugged_in_minimum_duration_hours=24" >/dev/null 2>&1

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
    [ -n "$tag" ] && content call --uri content://settings/global --method PUT_value \
        --arg "dropbox:$tag" --extra value:s:disabled >/dev/null 2>&1 &
done
wait
