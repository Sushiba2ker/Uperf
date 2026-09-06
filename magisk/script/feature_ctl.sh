#!/system/bin/sh
# Uperf runtime feature controller.
# Reads and updates the user-owned features.conf file.

BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/pathinfo.sh"
. "$BASEDIR/libcommon.sh"
. "$BASEDIR/libuperf.sh"
. "$BASEDIR/feature_runtime.sh"

is_feature_name() {
    for feature in $FEATURE_KEYS; do
        [ "$feature" = "$1" ] && return 0
    done
    return 1
}

feature_status() {
    printf '{"status":"ok"'
    for feature in $FEATURE_KEYS; do
        printf ',"%s":%s' "$feature" "$(feature_value "$feature" 1)"
    done
    printf '}\n'
}

feature_error() {
    printf '{"status":"error","message":"%s"}\n' "$1"
}

feature_disabled() {
    printf '{"status":"disabled","feature":"%s"}\n' "$1"
}

start_module() {
    sh "$SCRIPT_PATH/initsvc.sh" >/dev/null 2>&1 &
}

run_action() {
    local action="$1"

    if [ "$action" = "reapply" ]; then
        if ! feature_enabled module_enabled; then
            feature_disabled module_enabled
            return 0
        fi
        reapply_enabled_features
        printf '{"status":"ok","action":"reapply"}\n'
        return 0
    fi

    case "$action" in
        ram_clean|zram_compact|google_jobs)
            ;;
        restart)
            if ! feature_enabled uperf; then
                feature_disabled uperf
                return 0
            fi
            stop_feature_runtime uperf
            uperf_start >/dev/null 2>&1
            if feature_enabled powercfg; then
                run_startup_feature powercfg >/dev/null 2>&1
            fi
            printf '{"status":"ok","action":"restart"}\n'
            return 0
            ;;
        *)
            feature_error "unknown action"
            return 2
            ;;
    esac

    if ! feature_enabled "$action"; then
        feature_disabled "$action"
        return 0
    fi

    case "$action" in
        ram_clean)
            sh "$SCRIPT_PATH/ram_clean.sh"
            ;;
        zram_compact)
            compact_memory_pools
            printf '{"status":"ok","action":"zram_compact"}\n'
            ;;
        google_jobs)
            cancel_google_jobs
            printf '{"status":"ok","action":"google_jobs"}\n'
            ;;
    esac
}

command="$1"
case "$command" in
    status)
        feature_status
        ;;
    set)
        key="$2"
        value="$3"
        if ! is_feature_name "$key"; then
            feature_error "unknown feature"
            exit 2
        fi
        case "$value" in
            0|1) ;;
            *)
                feature_error "value must be 0 or 1"
                exit 2
                ;;
        esac
        if ! set_feature_value "$key" "$value"; then
            feature_error "cannot update features.conf"
            exit 1
        fi

        case "$key" in
            module_enabled)
                if [ "$value" = "1" ]; then
                    start_module
                else
                    stop_all_features
                fi
                ;;
            *)
                if [ "$value" = "1" ]; then
                    feature_enabled module_enabled && apply_feature_runtime "$key" >/dev/null 2>&1
                else
                    stop_feature_runtime "$key"
                fi
                ;;
        esac

        active=0
        feature_enabled "$key" && active=1
        printf '{"status":"ok","feature":"%s","enabled":%s,"active":%s}\n' \
            "$key" "$(feature_value "$key" 1)" "$active"
        ;;
    run)
        run_action "$2"
        ;;
    *)
        feature_error "usage: feature_ctl.sh status | set <feature> <0|1> | run <action>"
        exit 2
        ;;
esac
