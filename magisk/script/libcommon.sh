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

###############################
# Basic tool functions
###############################

# $1:value $2:filepaths
lock_val() {
    for p in $2; do
        if [ -f "$p" ]; then
            chown root:root "$p"
            chmod 0666 "$p"
            echo "$1" >"$p"
            chmod 0444 "$p"
        fi
    done
}

# $1:value $2:filepaths
mask_val() {
    touch /data/local/tmp/mount_mask
    for p in $2; do
        if [ -f "$p" ]; then
            umount "$p"
            chmod 0666 "$p"
            echo "$1" >"$p"
            mount --bind /data/local/tmp/mount_mask "$p"
        fi
    done
}

# $1:value $2:filepaths
mutate() {
    for p in $2; do
        if [ -f "$p" ]; then
            chmod 0666 "$p"
            echo "$1" >"$p"
        fi
    done
}

# $1:file path
lock() {
    if [ -f "$1" ]; then
        chown root:root "$1"
        chmod 0444 "$1"
    fi
}

# $1:value $2:list
has_val_in_list() {
    for item in $2; do
        if [ "$1" == "$item" ]; then
            echo "true"
            return
        fi
    done
    echo "false"
}

###############################
# Config File Operator
###############################

# $1:key $return:value(string)
read_cfg_value() {
    local value=""
    if [ -f "$PANEL_FILE" ]; then
        value="$(grep -i "^$1=" "$PANEL_FILE" | head -n 1 | tr -d ' ' | cut -d= -f2)"
    fi
    echo "$value"
}

###############################
# Runtime Feature Switches
###############################

# $1:key $2:default $return:value(0|1)
feature_value() {
    local key="$1"
    local default="${2:-1}"
    local value=""

    if [ -f "$FEATURE_FILE" ]; then
        value="$(grep -E "^${key}=" "$FEATURE_FILE" 2>/dev/null | head -n 1 | cut -d= -f2- | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')"
    fi

    case "$value" in
        1|true|on|yes|enabled) echo 1 ;;
        0|false|off|no|disabled) echo 0 ;;
        *) echo "$default" ;;
    esac
}

# $1:key
feature_enabled() {
    [ "$1" = "module_enabled" ] || [ "$(feature_value module_enabled 1)" = "1" ] || return 1
    [ "$(feature_value "$1" 1)" = "1" ]
}

# $1:key $2:value(0|1)
set_feature_value() {
    local key="$1"
    local value="$2"
    local temp_file="${FEATURE_FILE}.tmp.$$"

    mkdir -p "$USER_PATH" || return 1
    if [ -f "$FEATURE_FILE" ]; then
        sed "/^${key}=/d" "$FEATURE_FILE" >"$temp_file" || {
            rm -f "$temp_file"
            return 1
        }
    else
        : >"$temp_file" || return 1
    fi
    printf '%s=%s\n' "$key" "$value" >>"$temp_file" || {
        rm -f "$temp_file"
        return 1
    }
    chmod 0600 "$temp_file"
    mv -f "$temp_file" "$FEATURE_FILE"
}

# $1:name, kill the managed background process for a feature
stop_managed_process() {
    local name="$1"
    local pid_file="${RUNTIME_PATH}/${name}.pid"
    local pid=""
    local proc_cmd=""
    local waited=0

    if [ -f "$pid_file" ]; then
        pid="$(cat "$pid_file" 2>/dev/null)"
        case "$pid" in
            ''|*[!0-9]*) ;;
            *)
                proc_cmd="$(cat "/proc/$pid/cmdline" 2>/dev/null)"
                case "$proc_cmd" in
                    *"$name.sh"*)
                        kill "$pid" 2>/dev/null
                        while [ "$waited" -lt 5 ] && kill -0 "$pid" 2>/dev/null; do
                            sleep 1
                            waited=$((waited + 1))
                        done
                        kill -9 "$pid" 2>/dev/null
                        ;;
                esac
                ;;
        esac
        rm -f "$pid_file"
    fi
}

# $1:content
write_panel() {
    echo "$1" >>"$PANEL_FILE"
}

clear_panel() {
    true >"$PANEL_FILE"
}

wait_until_login() {
    # in case of /data encryption is disabled
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 1
    done

    # we doesn't have the permission to rw "/sdcard" before the user unlocks the screen
    local test_file="/sdcard/Android/.PERMISSION_TEST"
    true >"$test_file"
    while [ ! -f "$test_file" ]; do
        true >"$test_file"
        sleep 1
    done
    rm "$test_file"
}

###############################
# Log
###############################

# $1:content
log() {
    echo "$1" >>"$LOG_FILE"
}

clear_log() {
    true >"$LOG_FILE"
}
