#!/usr/bin/env bash
#
# uos-auto-upgrade.sh
# 根据 dbus.txt 中统信 UOS 更新流程自动完成：
#   1. 检查更新（UpdateSource）
#   2. 判断是否存在系统更新（GetUpdateLogs）
#   3. 下载更新（PrepareDistUpgradePartly）
#   4. 忽略备份失败并执行系统升级（DistUpgradePartly, needBackup=false）
#

set -u

DEST="com.deepin.lastore"
ROOT="/com/deepin/lastore"
UPDATE_TYPE="${UPDATE_TYPE:-5}"          # GetUpdateLogs 的 updateType
UPGRADE_MODE="${UPGRADE_MODE:-1}"        # system_upgrade
POLL_INTERVAL="${POLL_INTERVAL:-3}"      # 任务状态轮询间隔，秒
CHECK_TIMEOUT="${CHECK_TIMEOUT:-600}"    # 检查更新超时，秒
DOWNLOAD_TIMEOUT="${DOWNLOAD_TIMEOUT:-3600}"  # 下载更新超时，秒
UPGRADE_TIMEOUT="${UPGRADE_TIMEOUT:-7200}"    # 系统升级超时，秒
LOG_FILE="${LOG_FILE:-/tmp/uos-auto-upgrade.log}"

log() {
    printf '%s %s\n' "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"
}

die() {
    local message="${1:-未知错误}"
    local code="${2:-1}"
    log "[错误] ${message}"
    exit "$code"
}

# 调用 /com/deepin/lastore 上的方法
lastore_call() {
    dbus-send --system \
        --print-reply \
        --reply-timeout=5000 \
        --dest="$DEST" "$ROOT" "$@"
}

# 读取任意 job 路径下的 com.deepin.lastore.Job.Status。
# 查询失败时返回 __ERROR__，便于区分“任务已完成并被清理”和“仍在运行”。
get_job_status() {
    local job_path="$1"
    local output=""
    local rc=0
    local status=""

    output="$(dbus-send --system \
        --print-reply \
        --reply-timeout=5000 \
        --dest="$DEST" "$job_path" \
        org.freedesktop.DBus.Properties.Get \
        "string:com.deepin.lastore.Job" "string:Status" 2>&1)"
    rc=$?

    if (( rc != 0 )) || printf '%s\n' "$output" | grep -q '^Error'; then
        printf '__ERROR__\n'
        return
    fi

    status="$(printf '%s\n' "$output" |
        sed -n 's/^[[:space:]]*variant[[:space:]]*string[[:space:]]*"\([^"]*\)"/\1/p' |
        tail -n 1)"

    if [[ -z "$status" ]]; then
        printf '__EMPTY__\n'
    else
        printf '%s\n' "$status"
    fi
}

# 判断指定 job path 是否仍在 Manager.JobList 中
manager_has_job() {
    local job_path="$1"
    dbus-send --system \
        --print-reply \
        --reply-timeout=5000 \
        --dest="$DEST" "$ROOT" \
        org.freedesktop.DBus.Properties.Get \
        "string:com.deepin.lastore.Manager" "string:JobList" 2>/dev/null |
        grep -Fq "object path \"${job_path}\""
}

# 从 dbus-send 输出中提取 object path
extract_object_path() {
    sed -n 's/^[[:space:]]*object path "\([^"]*\)"/\1/p' | tail -n 1
}

# 从 dbus-send 输出中提取 string 返回值
extract_string_value() {
    sed -n 's/^[[:space:]]*string "\(.*\)"$/\1/p' | tail -n 1
}

# 读取 com.deepin.lastore.Updater 的属性
get_updater_property() {
    local property="$1"
    dbus-send --system \
        --print-reply \
        --reply-timeout=5000 \
        --dest="$DEST" "$ROOT" \
        org.freedesktop.DBus.Properties.Get \
        "string:com.deepin.lastore.Updater" "string:${property}"
}

# 判断 ClassifiedUpdatablePackages 中 system_upgrade 数组是否非空。
# 空数组表示当前没有可安装的系统更新，即使 GetUpdateLogs 返回了版本日志。
classified_has_system_upgrade() {
    local output="$1"
    printf '%s\n' "$output" | awk '
        /^[[:space:]]*string "system_upgrade"[[:space:]]*$/ {
            in_system = 1
            next
        }
        in_system && /^[[:space:]]*dict entry\(/ {
            in_system = 0
            next
        }
        in_system && /^[[:space:]]*string "/ {
            found = 1
            exit
        }
        END { exit (found ? 0 : 1) }
    '
}

wait_for_job() {
    local job_path="$1"
    local job_name="$2"
    local timeout="$3"
    local elapsed=0
    local status=""
    local missing_count=0

    while (( elapsed < timeout )); do
        status="$(get_job_status "$job_path")"

        # 快速任务可能在首次轮询前就已经结束并从 JobList 清理，
        # 此时 Job.Status 查询会报 UnknownObject。
        if [[ "$status" == "__ERROR__" ]]; then
            if manager_has_job "$job_path"; then
                log "[${job_name}] 状态查询暂时失败，但任务仍在任务列表中，继续等待..."
                status=""
            else
                missing_count=$((missing_count + 1))
                log "[${job_name}] 任务对象已不可见（可能已完成并清理）"
                if (( missing_count >= 2 )); then
                    return 0
                fi
                status=""
            fi
        else
            missing_count=0
        fi

        if [[ -n "$status" ]]; then
            log "[${job_name}] 状态: ${status}"
            case "$status" in
                __EMPTY__)
                    ;;
                succeed|end)
                    return 0
                    ;;
                failed|cancelled)
                    return 1
                    ;;
            esac
        fi
        sleep "$POLL_INTERVAL"
        elapsed=$((elapsed + POLL_INTERVAL))
    done

    log "[${job_name}] 等待超时"
    return 2
}

call_and_get_job_path() {
    local call_name="$1"
    shift
    local output=""
    local rc=0
    local job_path=""

    output="$("$@" 2>&1)"
    rc=$?
    if (( rc != 0 )) || printf '%s\n' "$output" | grep -q '^Error'; then
        log "[${call_name}] D-Bus 调用失败:"
        printf '%s\n' "$output" | tee -a "$LOG_FILE"
        return 1
    fi

    job_path="$(printf '%s\n' "$output" | extract_object_path)"
    if [[ -z "$job_path" ]]; then
        log "[${call_name}] 未能从返回结果中解析任务路径:"
        printf '%s\n' "$output" | tee -a "$LOG_FILE"
        return 1
    fi

    printf '%s\n' "$job_path"
}

main() {
    log "==================== 开始 UOS 自动升级 ===================="
    command -v dbus-send >/dev/null 2>&1 || die "未找到 dbus-send"

    # 1. 检查更新
    log "[1/4] 检查更新源..."
    local update_job=""
    update_job="$(call_and_get_job_path "UpdateSource" lastore_call com.deepin.lastore.Manager.UpdateSource)" ||
        die "检查更新失败"
    log "[1/4] 更新源刷新任务: ${update_job}"

    wait_for_job "$update_job" "更新源刷新" "$CHECK_TIMEOUT" || die "检查更新失败或超时"

    # 2. 判断是否有系统更新
    log "[2/4] 查询更新日志..."
    local logs_output=""
    local rc=0
    logs_output="$(lastore_call com.deepin.lastore.Manager.GetUpdateLogs "uint64:${UPDATE_TYPE}" 2>&1)"
    rc=$?
    if (( rc != 0 )) || printf '%s\n' "$logs_output" | grep -q '^Error'; then
        printf '%s\n' "$logs_output" | tee -a "$LOG_FILE"
        die "查询更新日志失败"
    fi

    local update_json=""
    update_json="$(printf '%s\n' "$logs_output" | extract_string_value)"
    if [[ -z "$update_json" ]]; then
        printf '%s\n' "$logs_output" | tee -a "$LOG_FILE"
        die "无法解析更新日志"
    fi
    log "[2/4] 更新日志: ${update_json}"

    # GetUpdateLogs 返回的日志并不代表当前一定有可安装更新。
    # 以 Updater.ClassifiedUpdatablePackages 的实际可更新包列表为准。
    local classified_output=""
    local classified_rc=0
    classified_output="$(get_updater_property ClassifiedUpdatablePackages 2>&1)"
    classified_rc=$?
    if (( classified_rc != 0 )) || printf '%s\n' "$classified_output" | grep -q '^Error'; then
        printf '%s\n' "$classified_output" | tee -a "$LOG_FILE"
        die "查询可更新包列表失败"
    fi
    log "[2/4] 可更新包列表:"
    printf '%s\n' "$classified_output" | tee -a "$LOG_FILE"

    if ! classified_has_system_upgrade "$classified_output"; then
        log "未检测到需要更新的内容，流程结束。"
        exit 0
    fi
    log "检测到系统更新。"

    # 3. 下载更新
    log "[3/4] 开始下载系统更新..."
    local prepare_job=""
    prepare_job="$(call_and_get_job_path "PrepareDistUpgradePartly" lastore_call \
        com.deepin.lastore.Manager.PrepareDistUpgradePartly "uint64:${UPGRADE_MODE}")" ||
        die "创建下载任务失败"
    log "[3/4] 下载任务: ${prepare_job}"

    wait_for_job "$prepare_job" "下载更新" "$DOWNLOAD_TIMEOUT" || die "下载更新失败或超时"

    # 4. 忽略备份失败，执行系统升级。
    # dbus.txt 中“继续更新”的动作为：
    # dbus-send ... com.deepin.lastore.Manager.DistUpgradePartly uint64:1 boolean:false
    log "[4/4] 执行系统升级（needBackup=false，忽略备份失败）..."
    local upgrade_job=""
    upgrade_job="$(call_and_get_job_path "DistUpgradePartly" lastore_call \
        com.deepin.lastore.Manager.DistUpgradePartly "uint64:${UPGRADE_MODE}" boolean:false)" ||
        die "创建系统升级任务失败"
    log "[4/4] 系统升级任务: ${upgrade_job}"

    wait_for_job "$upgrade_job" "系统升级" "$UPGRADE_TIMEOUT" || die "系统升级失败或超时"

    log "系统升级流程已完成。若系统提示需要重启，请及时重启系统。"
    log "==================== UOS 自动升级结束 ===================="
}

main "$@"
