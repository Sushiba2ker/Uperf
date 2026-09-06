#!/system/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
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

BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libsysinfo.sh

# $1:error_message
abort() {
    echo "$1"
    echo "! Uperf installation failed."
    exit 1
}

# $1:file_node $2:owner $3:group $4:permission $5:secontext
set_perm() {
    chown $2:$3 $1
    chmod $4 $1
    chcon $5 $1
}

# $1:directory $2:owner $3:group $4:dir_permission $5:file_permission $6:secontext
set_perm_recursive() {
    find $1 -type d 2>/dev/null | while read dir; do
        set_perm $dir $2 $3 $4 $6
    done
    find $1 -type f -o -type l 2>/dev/null | while read file; do
        set_perm $file $2 $3 $5 $6
    done
}

install_uperf() {
    echo "- Finding platform specified config"
    echo "- ro.board.platform=$(getprop ro.board.platform)"
    echo "- ro.product.board=$(getprop ro.product.board)"

    local target
    cfgname=""
    target="$(getprop ro.board.platform)"
    cfgname="$(get_config_name $target)"
    if [ "$cfgname" == "unsupported" ]; then
        target="$(getprop ro.product.board)"
        cfgname="$(get_config_name $target)"
    fi

    if [ "$cfgname" == "unsupported" ] || [ ! -f $MODULE_PATH/config/$cfgname.json ]; then
        abort "! Target [$target] not supported."
    fi

    echo "- Uperf config is located at $USER_PATH"
    mkdir -p $USER_PATH
    mv -f $USER_PATH/uperf.json $USER_PATH/uperf.json.bak
    cp -f $MODULE_PATH/config/$cfgname.json $USER_PATH/uperf.json
    [ ! -e "$USER_PATH/perapp_powermode.txt" ] && cp "$MODULE_PATH/config/perapp_powermode.txt" "$USER_PATH/perapp_powermode.txt"
    if [ -f "$MODULE_PATH/config/features.conf" ] && [ ! -e "$FEATURE_FILE" ]; then
        cp "$MODULE_PATH/config/features.conf" "$FEATURE_FILE"
    fi
    # Clean vendor thermal overlay if device is not Google Tensor G3
    if [ "$cfgname" != "gs301" ]; then
        rm -f "$MODULE_PATH/system/vendor/etc/thermal_info_config.json" "$MODULE_PATH/system/vendor/etc/thermal_info_config_charge.json" 2>/dev/null
    fi

    rm -rf $MODULE_PATH/config
    chmod 755 $MODULE_PATH/*.sh $MODULE_PATH/script/*.sh 2>/dev/null
    set_perm_recursive $BIN_PATH 0 0 0755 0755 u:object_r:system_file:s0
}


check_asopt() {
    echo "❗ 即将为您安装A-SOUL"
    echo "❗ 此模块功能为放置游戏线程，优化游戏流畅度"
    echo "❗ 作者个人建议安装，因为绝大多数厂商的线程都是乱放的"
    echo "❗ 此线程可极大优化游戏流畅度"
    echo "❗ 单击音量上键即可确认更新或安装"
    echo "❗ 单击音量下键取消更新或安装（不推荐)"
    key_click=""
    while [ "$key_click" = "" ]; do
        key_click="$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_')"
        sleep 0.2
    done
    case "$key_click" in
        "KEY_VOLUMEUP")
            echo "❗您已确认更新，请稍候"
            install_corp
            echo "* 已为您安装ASOUL❤️"
            echo "* 感谢您的支持与信任😁"
        ;;
        *)
            echo "❗非常遗憾"
            echo "❗已为您取消更新ASOUL💔"
    esac
    rm -rf "$MODULE_PATH"/modules/asoulopt.zip
}

get_value() {
   echo "$(grep -E "^$1=" "$2" | head -n 1 | cut -d= -f2)"
}

install_corp() {
    if [ -d "/data/adb/modules/unity_affinity_opt" ] || [ -d "/data/adb/modules_update/unity_affinity_opt" ]; then
        rm /data/adb/modules*/unity_affinity_opt
    fi
    CUR_ASOPT_VERSIONCODE="$(get_value ASOPT_VERSIONCODE "$MODULE_PATH"/module.prop)"
    asopt_module_version="0"
    if [ -f "/data/adb/modules/asoul_affinity_opt/module.prop" ]; then
        asopt_module_version="$(get_value versionCode /data/adb/modules/asoul_affinity_opt/module.prop)"
        echo "- AsoulOpt...current:$asopt_module_version"
        echo "- AsoulOpt...embeded:$CUR_ASOPT_VERSIONCODE"
        if [ "$CUR_ASOPT_VERSIONCODE" -gt "$asopt_module_version" ]; then
            
            echo "* 您正在使用旧版asopt️"
            echo "* Uperf Game Turbo将为您更新至模块内版本️"
            killall -9 AsoulOpt
            rm -rf /data/adb/modules*/asoul_affinity_opt
            echo "- 正在为您安装asopt"
            magisk --install-module "$MODULE_PATH"/modules/asoulopt.zip
        else
            echo "* 您正在使用新版本的asopt"
            echo "* Uperf Game Turbo将不予操作️"
        fi
    else
        echo "* 您尚未安装asopt"
        echo "* Uperf Game Turbo将尝试为您第一次安装️"
        killall -9 AsoulOpt
        rm -rf /data/adb/modules*/asoul_affinity_opt
        echo "- 正在为您安装asopt"
        magisk --install-module "$MODULE_PATH"/modules/asoulopt.zip
    fi
    rm -rf "$MODULE_PATH"/modules/asoulopt.zip
}

fix_module_prop() {
    mkdir -p /data/adb/modules/uperf/
    cp -f "$MODULE_PATH/module.prop" /data/adb/modules/uperf/module.prop
}

unlock_limit(){
if [[ ! -d $MODPATH/system/vendor/etc/perf/ ]];then
  dir=$MODPATH/system/vendor/etc/perf/
  mkdir -p $dir
fi

for i in ` ls /system/vendor/etc/perf/ `
do
  touch $dir/$i 
done
}

echo ""
echo "* 原模块地址 Uperf https://github.com/yc9559/uperf/"
echo "* Author: Matt Yang ❤️吟惋兮❤️改"
echo "* Version: Game Turbo1.31 based on uperf904"
echo "* 请不要破坏Uperf运行环境"
echo "* 模块会附带安装asopt"
echo "* "
echo "* 极速模式请自备散热，删除温控体验更佳"
echo "* 本模块与限频模块、部分优化模块冲突"
echo "* 模块可能与第三方内核冲突"
echo "* 请自行事先询问内核作者"
echo "* 请不要破坏Uperf Game Turbo运行环境!!!"
echo "* 请不要自行更改/切换CPU调速器!!!"
echo "* "
echo "* dnmd.leijun.MIUI.jinfan😅"
echo "* WoShaNiMa.OnePlus.ColorOS.nimasile😅"
echo "* "
echo "* ❤️吟惋兮❤️"
echo "- 正在为您安装Uperf Game Turbo❤️"
install_uperf
#unlock_limit
echo "* Uperf Game Turbo installed successfully."
if [ "$cfgname" = "gs301" ]; then
    echo "* Skip asopt on Tensor G3 (9 cores; bundled AsoulOpt has no cpu8 mask)."
    rm -rf "$MODULE_PATH"/modules/asoulopt.zip
else
    install_corp
    echo "* asopt installed."
fi
echo "* Reboot to activate module."
fix_module_prop