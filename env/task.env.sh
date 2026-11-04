#!/usr/bin/env bash

# Usage: bash task.env.sh <task-version>
#    <task-version> example:
#      - v3.48.0
#
# https://github.com/go-task/task/releases/download/v3.48.0/task_linux_amd64.tar.gz
# https://github.com/go-task/task/releases/download/v3.48.0/task_linux_arm64.tar.gz
# https://github.com/go-task/task/releases/download/v3.48.0/task_darwin_amd64.tar.gz
# https://github.com/go-task/task/releases/download/v3.48.0/task_darwin_arm64.tar.gz

if [ ! -f "${HOME:?}/Applications/task-${1:?}/task" ]; then
  task_version="${1:?}" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] task ${task_version:?} is installing ..." && \
  rm    -r -f "${HOME:?}/Applications/task-${task_version}/" && \
  mkdir -p "${HOME:?}/Applications/task-${task_version}/" && \
  # download and extract
  case $(uname -s)-$(uname -m) in
    Linux-x86_64   | Linux-amd64)  \
      curl -fL "https://github.com/go-task/task/releases/download/${task_version:?}/task_linux_amd64.tar.gz" | \
      tar -xz -C "${HOME:?}/Applications/task-${task_version}/" ;;
    Linux-aarch64  | Linux-arm64)  \
      curl -fL "https://github.com/go-task/task/releases/download/${task_version:?}/task_linux_arm64.tar.gz" | \
      tar -xz -C "${HOME:?}/Applications/task-${task_version}/" ;;
    Darwin-x86_64  | Darwin-amd64) \
      curl -fL "https://github.com/go-task/task/releases/download/${task_version:?}/task_darwin_amd64.tar.gz" | \
      tar -xz -C "${HOME:?}/Applications/task-${task_version}/" ;;
    Darwin-aarch64 | Darwin-arm64) \
      curl -fL "https://github.com/go-task/task/releases/download/${task_version:?}/task_darwin_arm64.tar.gz" | \
      tar -xz -C "${HOME:?}/Applications/task-${task_version}/" ;;
    *) echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ ERROR ] unsupported platform [$(uname -s)-$(uname -m)]" && false ;;
  esac && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] task ${task_version:?} installed."
fi && \
export PATH="${HOME:?}/Applications/task-${1:?}:${PATH}"
