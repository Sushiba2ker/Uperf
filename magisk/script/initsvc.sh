#!/vendor/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
# Enhanced for Google Tensor G3 by Sushiba
#

BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libuperf.sh

# create busybox symlinks
$BIN_PATH/busybox/busybox --install -s $BIN_PATH/busybox

# support vtools
cp -af $SCRIPT_PATH/vtools_powercfg.sh /data/powercfg.sh
cp -af $SCRIPT_PATH/vtools_powercfg.sh /data/powercfg-base.sh
cp -af $SCRIPT_PATH/powercfg.json /data/powercfg.json
chmod 755 /data/powercfg.sh
chmod 755 /data/powercfg-base.sh
echo "sh $SCRIPT_PATH/powercfg_main.sh \"\$1\"" >>/data/powercfg.sh

wait_until_login

sh $SCRIPT_PATH/powercfg_once.sh
sh $SCRIPT_PATH/platform_special.sh
sh $SCRIPT_PATH/ktweak_opt.sh
sh $SCRIPT_PATH/sys_opt.sh
sh $SCRIPT_PATH/gms_freeze.sh &
sh $SCRIPT_PATH/gms_doze.sh &
sh $SCRIPT_PATH/thermal_guard.sh &
sh $SCRIPT_PATH/powercfg_main.sh auto
uperf_start
