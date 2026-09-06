#!/system/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
# Enhanced for Google Tensor G3 by Sushiba
#

BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/pathinfo.sh"
. "$BASEDIR/libsysinfo.sh"

abort() {
    echo "$1"
    echo "! Cài đặt Uperf Sushiba thất bại."
    exit 1
}

# $1:file_node $2:owner $3:group $4:permission $5:secontext
set_perm() {
    chown "$2:$3" "$1" 2>/dev/null
    chmod "$4" "$1" 2>/dev/null
    chcon "$5" "$1" 2>/dev/null
}

# $1:directory $2:owner $3:group $4:dir_permission $5:file_permission $6:secontext
set_perm_recursive() {
    find "$1" -type d 2>/dev/null | while read -r dir; do
        set_perm "$dir" "$2" "$3" "$4" "$6"
    done
    find "$1" -type f -o -type l 2>/dev/null | while read -r file; do
        set_perm "$file" "$2" "$3" "$5" "$6"
    done
}

install_uperf() {
    local target
    cfgname=""
    target="$(getprop ro.board.platform)"
    cfgname="$(get_config_name "$target")"
    if [ "$cfgname" = "unsupported" ]; then
        target="$(getprop ro.product.board)"
        cfgname="$(get_config_name "$target")"
    fi

    if [ "$cfgname" = "unsupported" ] || [ ! -f "$MODULE_PATH/config/$cfgname.json" ]; then
        abort "! Thiết bị [$target] không được hỗ trợ (chỉ hỗ trợ Tensor G3)."
    fi

    echo "- Nhận diện: $target ($cfgname)"
    mkdir -p "$USER_PATH"
    [ -f "$USER_PATH/uperf.json" ] && mv -f "$USER_PATH/uperf.json" "$USER_PATH/uperf.json.bak"
    cp -f "$MODULE_PATH/config/$cfgname.json" "$USER_PATH/uperf.json"
    [ ! -e "$USER_PATH/perapp_powermode.txt" ] && cp "$MODULE_PATH/config/perapp_powermode.txt" "$USER_PATH/perapp_powermode.txt"
    if [ -f "$MODULE_PATH/config/features.conf" ] && [ ! -e "$FEATURE_FILE" ]; then
        cp "$MODULE_PATH/config/features.conf" "$FEATURE_FILE"
    fi

    # Clean vendor thermal overlay if device is not Google Tensor G3
    if [ "$cfgname" != "gs301" ]; then
        rm -f "$MODULE_PATH/system/vendor/etc/thermal_info_config.json" "$MODULE_PATH/system/vendor/etc/thermal_info_config_charge.json" 2>/dev/null
    fi

    rm -rf "$MODULE_PATH/config"
    rm -rf "$MODULE_PATH/modules" 2>/dev/null
    chmod 755 "$MODULE_PATH"/*.sh "$MODULE_PATH"/script/*.sh 2>/dev/null
    set_perm_recursive "$BIN_PATH" 0 0 0755 0755 u:object_r:system_file:s0
}

fix_module_prop() {
    mkdir -p /data/adb/modules/uperf/ 2>/dev/null
    cp -f "$MODULE_PATH/module.prop" /data/adb/modules/uperf/module.prop 2>/dev/null
}

echo ""
echo "************************************"
echo "           Uperf Sushiba            "
echo "    Tensor G3 Pure Hardware Boost   "
echo "          Author: Sushiba           "
echo "************************************"
install_uperf
fix_module_prop
echo "- Cài đặt hoàn tất."
echo "- Khởi động lại máy để kích hoạt!"
echo "************************************"
echo ""
