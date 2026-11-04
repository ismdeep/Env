#!/usr/bin/env bash

set -uo pipefail

readonly WECOM_APP_PATH='/opt/apps/com.qq.weixin.work.deepin/files'
readonly WECOM_BOTTLE_NAME='Deepin-WXWork'
readonly WECOM_MATCH_EXE='wxwork.exe'
readonly WECOM_WINEPREFIX="$HOME/.deepinwine/$WECOM_BOTTLE_NAME"
readonly DEEPINWINE_KILL_SH='/opt/deepinwine/tools/kill.sh'
readonly TERM_WAIT_SECONDS=3
readonly KILL_WAIT_SECONDS=1
readonly MAX_ROUNDS=3

find_wecom_pids() {
    ps -eo pid=,args= |
        WECOM_MATCH_PATH_ENV="$WECOM_APP_PATH/" \
        WECOM_MATCH_BOTTLE_ENV="$WECOM_BOTTLE_NAME" \
        WECOM_MATCH_EXE_ENV="$WECOM_MATCH_EXE" \
        awk '
            {
                line = tolower($0)
                if (index($0, ENVIRON["WECOM_MATCH_PATH_ENV"]) > 0 ||
                    index($0, ENVIRON["WECOM_MATCH_BOTTLE_ENV"]) > 0 ||
                    index(line, ENVIRON["WECOM_MATCH_EXE_ENV"]) > 0) {
                    print $1
                }
            }
        '
}

is_wecom_args() {
    local args=$1
    [[ "$args" == *"$WECOM_APP_PATH/"* ||
       "$args" == *"$WECOM_BOTTLE_NAME"* ||
       "${args,,}" == *"$WECOM_MATCH_EXE"* ]]
}

clean_wecom_wine_bottle() {
    if [[ -x "$DEEPINWINE_KILL_SH" ]]; then
        "$DEEPINWINE_KILL_SH" "$WECOM_BOTTLE_NAME" >/dev/null 2>&1 || true
        return 0
    fi

    local wineserver
    for wineserver in /opt/deepin-wine*-stable/bin/wineserver; do
        [[ -x "$wineserver" ]] || continue
        WINEPREFIX="$WECOM_WINEPREFIX" "$wineserver" -k >/dev/null 2>&1 || true
    done
}

main() {
    local round
    local pid
    local args
    local -a pids=()
    local -a survivors=()

    # 企业微信由 deepin-wine 容器启动，先关闭整个 WXWork 容器，避免 wineserver 残留
    clean_wecom_wine_bottle

    # 最多清理 3 轮，处理守护进程重新拉起的子进程
    for ((round = 1; round <= MAX_ROUNDS; round++)); do
        readarray -t pids < <(find_wecom_pids)

        if (( ${#pids[@]} == 0 )); then
            echo "企业微信进程清理完成。"
            return 0
        fi

        echo "清理进程 ${pids[*]} ..."
        kill -TERM "${pids[@]}" 2>/dev/null || true
        sleep "$TERM_WAIT_SECONDS"

        # 对仍然存在的企业微信进程强制终止；先确认命令行，避免 PID 复用误杀
        readarray -t pids < <(find_wecom_pids)
        survivors=()
        for pid in "${pids[@]}"; do
            echo "清理 pid ${pid} ..."
            args="$(ps -p "$pid" -o args= 2>/dev/null || true)"
            if is_wecom_args "$args"; then
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
    readarray -t pids < <(find_wecom_pids)

    if (( ${#pids[@]} > 0 )); then
        echo "清理失败，仍有企业微信进程："
        ps -p "$(IFS=,; echo "${pids[*]}")" -o pid=,comm= 2>/dev/null || true
        return 1
    fi

    echo "企业微信进程清理完成"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
