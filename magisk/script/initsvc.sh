#!/vendor/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
# Enhanced for Google Tensor G3 by Sushiba
#

BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/pathinfo.sh"
. "$BASEDIR/libcommon.sh"
. "$BASEDIR/libuperf.sh"
. "$BASEDIR/feature_runtime.sh"

# create busybox symlinks
$BIN_PATH/busybox/busybox --install -s $BIN_PATH/busybox

# support vtools
cp -af "$SCRIPT_PATH/vtools_powercfg.sh" /data/powercfg.sh
cp -af "$SCRIPT_PATH/vtools_powercfg.sh" /data/powercfg-base.sh
cp -af "$SCRIPT_PATH/powercfg.json" /data/powercfg.json
chmod 755 /data/powercfg.sh
chmod 755 /data/powercfg-base.sh

wait_until_login

if ! feature_enabled module_enabled; then
    log "Uperf runtime disabled by features.conf"
    exit 0
fi

for feature in $STARTUP_FEATURES; do
    feature_enabled "$feature" && run_startup_feature "$feature"
done
