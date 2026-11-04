#!/usr/bin/env bash

set -uo pipefail

readonly WPS_PATH='/opt/apps/cn.wps.wps-office-pro/files/kingsoft/wps-office/office6'
readonly TERM_WAIT_SECONDS=3
readonly KILL_WAIT_SECONDS=1
readonly MAX_ROUNDS=3

find_wps_pids() {
    ps -eo pid=,args= |
        WPS_MATCH_PATH="$WPS_PATH/" awk '
            index($0, ENVIRON["WPS_MATCH_PATH"]) > 0 {
                print $1
            }
        '
}

main() {
    local round
    local pid
    local args
    local -a pids=()
    local -a survivors=()

    # 最多清理 3 轮，处理守护进程重新拉起的子进程
    for ((round = 1; round <= MAX_ROUNDS; round++)); do
        readarray -t pids < <(find_wps_pids)

        if (( ${#pids[@]} == 0 )); then
            echo "WPS 进程清理完成。"
            return 0
        fi

        echo "清理进程 ${pids[*]} ..."
        kill -TERM "${pids[@]}" 2>/dev/null || true
        sleep "$TERM_WAIT_SECONDS"

        # 对仍然存在的 WPS 进程强制终止；先确认命令行，避免 PID 复用误杀
        readarray -t pids < <(find_wps_pids)
        survivors=()
        for pid in "${pids[@]}"; do
            echo "清理 pid ${pid} ..."
            args="$(ps -p "$pid" -o args= 2>/dev/null || true)"
            if [[ "$args" == *"$WPS_PATH/"* ]]; then
                survivors+=("$pid")
            fi
        done

        if (( ${#survivors[@]} > 0 )); then
            echo "第 ${round} 轮：仍有 ${#survivors[@]} 个进程存活，强制终止"
            kill -KILL "${survivors[@]}" 2>/dev/null || true
        fi
        sleep "$KILL_WAIT_SECONDS"
    done

    # 最终检查
    readarray -t pids < <(find_wps_pids)

    if (( ${#pids[@]} > 0 )); then
        echo "清理失败，仍有 WPS 进程："
        ps -p "$(IFS=,; echo "${pids[*]}")" -o pid=,comm= 2>/dev/null || true
        return 1
    fi

    echo "WPS 进程清理完成"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
