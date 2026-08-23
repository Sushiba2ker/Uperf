#!/system/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
# Enhanced for Google Tensor G3 (gs301) pure focus by Sushiba
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Runonce after boot, to speed up the transition of power modes in powercfg
#
# Tensor G3 pure focus: this module only installs on Google Tensor G3
# (see setup.sh / libsysinfo.sh), so all Qualcomm / MediaTek / Samsung /
# Xiaomi / OnePlus specific tuning has been intentionally removed.
#
# Safety invariants on Tensor G3:
# - vendor.power-hal-aidl MUST stay alive: SystemServer and SurfaceFlinger
#   depend on its Binder IPC; killing it hangs screen-unlock.
# - CPU uclamp / cpufreq nodes are NOT chmod-locked: locking them would
#   block the PowerHAL thermal mitigation and break unlock smoothness.
#   uperf daemon and powercfg_main.sh own the DVFS/cpuset policy.

BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh

clear_log
exec 1>$LOG_FILE
# exec 2>&1
echo "PATH=$PATH"
echo "sh=$(which sh)"

# Safety net: ensure all 9 physical cores (0-8) are online.
# Tensor keeps cores online by default; never lock the node so the
# PowerHAL/thermal stack can still offline if it must.
for i in 0 1 2 3 4 5 6 7 8; do
    [ -f "/sys/devices/system/cpu/cpu$i/online" ] && echo 1 > "/sys/devices/system/cpu/cpu$i/online" 2>/dev/null
done
