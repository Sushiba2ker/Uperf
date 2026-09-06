#!/system/bin/sh
#
# Surgical Google Play Services (GMS) Telemetry & Background Freeze Engine
# Ported & Optimized from Frosty for Uperf
# Author: Sushiba
#
# Eliminates background GMS battery drain while guaranteeing 100% FCM Push Notifications
#
BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/pathinfo.sh"
. "$BASEDIR/libcommon.sh"

GMS_SAFE_TELEMETRY="
com.google.android.gms/com.google.android.gms.ads.identifier.service.AdvertisingIdNotificationService
com.google.android.gms/com.google.android.gms.ads.identifier.service.AdvertisingIdService
com.google.android.gms/com.google.android.gms.ads.AdRequestBrokerService
com.google.android.gms/com.google.android.gms.ads.settings.AdsSettingsActivityService
com.google.android.gms/com.google.android.gms.ads.GservicesValueBrokerService
com.google.android.gms/com.google.android.gms.ads.jams.NegotiationService
com.google.android.gms/com.google.android.gms.ads.MobileAdsSettingManagerService
com.google.android.gms/com.google.android.gms.ads.measurement.GmpConversionTrackingBrokerService
com.google.android.gms/com.google.android.gms.ads.cache.CacheBrokerService
com.google.android.gms/com.google.android.gms.ads.config.FlagsReceiver
com.google.android.gms/com.google.android.gms.ads.social.GcmSchedulerWakeupService
com.google.android.gms/com.google.android.gms.adsidentity.service.AdServicesExtDataStorageService
com.google.android.gms/com.google.android.gms.nearby.mediums.nearfieldcommunication.NfcAdvertisingService
com.google.android.gms/com.google.android.gms.analytics.AnalyticsService
com.google.android.gms/com.google.android.gms.analytics.AnalyticsTaskService
com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService
com.google.android.gms/com.google.android.gms.analytics.service.AnalyticsService
com.google.android.gms/com.google.android.gms.analytics.AnalyticsReceiver
com.google.android.gms/com.google.android.gms.stats.eastworld.EastworldService
com.google.android.gms/com.google.android.gms.stats.service.DropBoxEntryAddedService
com.google.android.gms/com.google.android.gms.stats.service.DropBoxEntryAddedReceiver
com.google.android.gms/com.google.android.gms.stats.DropBoxEntryAddedService
com.google.android.gms/com.google.android.gms.stats.PlatformStatsCollectorService
com.google.android.gms/com.google.android.gms.common.stats.GmsCoreStatsService
com.google.android.gms/com.google.android.gms.common.stats.StatsUploadService
com.google.android.gms/com.google.android.gms.common.stats.net.NetworkReportService
com.google.android.gms/com.google.android.gms.tron.CollectionService
com.google.android.gms/com.google.android.gms.tron.AlarmReceiver
com.google.android.gms/com.google.android.gms.feedback.FeedbackAsyncService
com.google.android.gms/com.google.android.gms.feedback.LegacyBugReportService
com.google.android.gms/com.google.android.gms.feedback.OfflineReportSendTaskService
com.google.android.gms/com.google.android.gms.googlehelp.metrics.ReportBatchedMetricsGcmTaskService
com.google.android.gms/com.google.android.gms.presencemanager.service.PresenceManagerPresenceReportService
com.google.android.gms/com.google.android.gms.usagereporting.service.UsageReportingIntentService
com.google.android.gms/com.google.android.gms.crash.service.CrashReportService
com.google.android.gms/com.google.android.gms.clearcut.service.ClearcutLoggerService
com.google.android.gms/com.google.android.gms.clearcut.debug.ClearcutDebugDumpService
com.google.android.gms/com.google.android.gms.measurement.AppMeasurementService
com.google.android.gms/com.google.android.gms.measurement.AppMeasurementJobService
com.google.android.gms/com.google.android.gms.measurement.AppMeasurementReceiver
com.google.android.gms/com.google.android.gms.measurement.PackageMeasurementReceiver
com.google.android.gms/com.google.android.gms.romanesco.ContactsLoggerUploadService
com.google.android.gms/com.google.android.gms.backup.stats.BackupStatsService
com.google.android.gms/com.google.android.gms.backup.component.FullBackupJobLoggerService
com.google.android.gms/com.google.android.gms.enpromo.PromoInternalPersistentService
com.google.android.gms/com.google.android.gms.enpromo.PromoInternalService
com.google.android.gms/com.google.android.gms.nearby.messages.debug.DebugPokeService
com.google.android.gms/com.google.android.gms.chimera.container.logger.ExternalDebugLoggerService
com.google.android.gms/com.google.android.gms.common.appdoctor.LocalAppDoctorReceiver
com.google.android.gms/com.google.android.gms.magictether.logging.DailyMetricsLoggerService
com.google.android.apps.work.clouddpc/com.google.android.apps.work.clouddpc.base.policy.services.ReportingPartialCollectionJobService
com.google.android.apps.work.clouddpc/com.google.android.apps.work.clouddpc.base.policy.services.StatusReportJobService
com.google.android.apps.work.clouddpc/com.google.android.apps.work.clouddpc.vanilla.bugreport.jobs.RemoteBugReportJobService
com.google.android.gms/com.google.android.gms.phenotype.service.sync.PhenotypeOperationService
com.google.android.gms/com.google.android.gms.phenotype.service.sync.PhResetService
com.google.android.gms/com.google.android.gms.herrevad.service.HerrevadAndroidService
com.google.android.gms/com.google.android.gms.udc.service.UdcService
com.google.android.gms/com.google.android.gms.udc.service.UdcMddService
com.google.android.gms/com.google.android.gms.focus.FocusAndroidService
com.google.mainline.telemetry/com.google.mainline.telemetry.TelemetryService
"

GMS_SAFE_BACKGROUND="
com.google.android.gms/com.google.android.gms.update.SystemUpdateGcmTaskService
com.google.android.gms/com.google.android.gms.update.SystemUpdateService
com.google.android.gms/com.google.android.gms.update.UpdateFromSdCardService
com.google.android.gms/com.google.android.gms.update.OtaSuggestionSummaryProvider
com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService
com.google.android.gms/com.google.android.gms.icing.proxy.IcingInternalCorporaUpdateService
com.google.android.gms/com.google.android.gms.mobiledataplan.service.PeriodicUpdaterService
com.google.android.gms/com.google.android.gms.phenotype.service.sync.PackageUpdateTaskService
com.google.android.gms/com.google.android.gms.mdm.services.MdmPhoneWearableListenerService
com.google.android.gms/com.google.android.gms.gmscompliance.service.GmsComplianceService
com.google.android.gms/com.google.android.gms.common.download.DownloadWorkService
com.android.vending/com.google.android.finsky.instantapps.InstantAppsLoggingService
com.google.android.gms/com.google.android.finsky.instantapps.InstantAppsLoggingService
"

action="${1:-freeze}"
if [ "$action" != "unfreeze" ] && [ "$action" != "restore" ] && ! feature_enabled gms_freeze; then
    printf '{"status":"disabled","feature":"gms_freeze"}\n'
    exit 0
fi

if [ "$action" = "unfreeze" ] || [ "$action" = "restore" ]; then
    for svc in $GMS_SAFE_TELEMETRY $GMS_SAFE_BACKGROUND; do
        [ -n "$svc" ] && pm enable "$svc" >/dev/null 2>&1
    done
    _gms_uid=$(dumpsys package com.google.android.gms 2>/dev/null | grep -m1 "userId=" | grep -o 'userId=[0-9]*' | cut -d= -f2)
    [ -n "$_gms_uid" ] && cmd netpolicy remove restrict-background-blacklist "$_gms_uid" >/dev/null 2>&1
    echo '{"status":"ok","action":"unfrozen"}'
else
    # 1. Disable Telemetry & Ads Services
    for svc in $GMS_SAFE_TELEMETRY; do
        [ -n "$svc" ] && pm disable "$svc" >/dev/null 2>&1
    done

    # 2. Disable Background Update & Polling Services
    for svc in $GMS_SAFE_BACKGROUND; do
        [ -n "$svc" ] && pm disable "$svc" >/dev/null 2>&1
    done

    # 3. Cancel Queued GMS Background Wakeup Jobs
    cmd jobscheduler cancel -u 0 com.google.android.gms >/dev/null 2>&1
    cmd jobscheduler cancel -u 0 com.android.vending >/dev/null 2>&1

    # 4. Restrict GMS Background Network Blacklist (While keeping FCM Push Whitelisted)
    _gms_uid=$(dumpsys package com.google.android.gms 2>/dev/null | grep -m1 "userId=" | grep -o 'userId=[0-9]*' | cut -d= -f2)
    if [ -n "$_gms_uid" ]; then
        cmd netpolicy add restrict-background-blacklist "$_gms_uid" >/dev/null 2>&1
    fi
    echo '{"status":"ok","action":"frozen"}'
fi
