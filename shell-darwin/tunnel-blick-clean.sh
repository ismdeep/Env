#!/usr/bin/env bash

set -e

# 日志函数
# 日志颜色代码：URL_ADDRESS# 日志颜色代码：https://misc.flogisoft.com/bash/tip_colors_and_formatting
# 日志格式：时间 [日志级别] 日志内容
# 日志级别：DEBUG, INFO, OK, WARN, ERROR
# 日志颜色：蓝色, 青色, 绿色, 黄色, 红色
# 日志输出：标准输出, 标准错误
# 日志示例：2021-01-01 00:00:00 +0800 [ DEBUG ] hello world.
# 日志示例：2021-01-01 00:00:00 +0800 [ INFO ] hello world.
# 日志示例：2021-01-01 00:00:00 +0800 [ OK ] hello world.
# 日志示例：2021-01-01 00:00:00 +0800 [ WARN ] hello world.
# 日志示例：2021-01-01 00:00:00 +0800 [ ERROR ] hello world.
if [[ "${TERM}" =~ ^(xterm|screen|vt100) ]]; then
  log_debug() {   echo -e "$(date '+%Y-%m-%d %H:%M:%S %z') [ \033[34mDEBUG\033[0m ] $*"; }
  log_info() {    echo -e "$(date '+%Y-%m-%d %H:%M:%S %z') [ \033[36mINFO\033[0m ] $*"; }
  log_success() { echo -e "$(date '+%Y-%m-%d %H:%M:%S %z') [ \033[32mOK\033[0m ] $*"; }
  log_warn() {    echo -e "$(date '+%Y-%m-%d %H:%M:%S %z') [ \033[33mWARN\033[0m ] $*" >&2; }
  log_error() {   echo -e "$(date '+%Y-%m-%d %H:%M:%S %z') [ \033[31mERROR\033[0m ] $*" >&2; }
else
  log_debug() {   echo -e "$(date '+%Y-%m-%d %H:%M:%S %z') [ DEBUG ] $*"; }
  log_info() {    echo -e "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] $*"; }
  log_success() { echo -e "$(date '+%Y-%m-%d %H:%M:%S %z') [ OK ] $*"; }
  log_warn() {    echo -e "$(date '+%Y-%m-%d %H:%M:%S %z') [ WARN ] $*" >&2; }
  log_error() {   echo -e "$(date '+%Y-%m-%d %H:%M:%S %z') [ ERROR ] $*" >&2; }
fi

# shellcheck disable=SC2009
content="$(ps aux | grep -E 'tunnel|Tunnel' | grep -v 'tunnel-blick-clean' | grep -v grep || true)"

if [ "$(echo "${content}" | wc -l)" == "0" ]; then
  log_info "no process found."
  exit 0
fi

echo "${content}" | awk '{print $2}' | xargs sudo kill -9 >/dev/null 2>&1
log_info "all tunnel blick process cleaned."
