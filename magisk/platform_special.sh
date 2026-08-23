#!/system/bin/sh
#
# Copyright (C) 2023 Ham Jin & yinwanxi
# Tensor G3 (gs301) pure focus by Sushiba
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
# (see setup.sh / libsysinfo.sh). All Qualcomm KGSL / MediaTek FPSGO-PPM /
# OnePlus / Xiaomi platform hacks have been removed because they target
# non-existent sysfs nodes on Tensor and would fight the PowerHAL.
#
# On Tensor there is nothing to "special-case" here: uperf owns the
# scheduler/cpuset policy and powercfg_main.sh owns the hardware clamps.

exit 0
