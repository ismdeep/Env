#!/usr/bin/env bash

# Usage: bash jq.env.sh <jq-version>
#    <jq-version> example:
#      - 1.8.1
#
# https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-linux-amd64
# https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-linux-arm64
# https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-macos-amd64
# https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-macos-arm64

if [ ! -f "${HOME:?}/Applications/jq-${1:?}/jq" ]; then
  jq_version="${1:?}" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] jq ${jq_version:?} is installing ..." && \
  rm    -r -f "${HOME:?}/Applications/jq-${jq_version}/" && \
  mkdir -p "${HOME:?}/Applications/jq-${jq_version}/" && \
  case $(uname -s)-$(uname -m) in
    Linux-x86_64   | Linux-amd64)  \
      curl -fL -o "${HOME:?}/Applications/jq-${jq_version}/jq" \
        "https://github.com/jqlang/jq/releases/download/jq-${jq_version:?}/jq-linux-amd64" ;;
    Linux-aarch64  | Linux-arm64)  \
      curl -fL -o "${HOME:?}/Applications/jq-${jq_version}/jq" \
        "https://github.com/jqlang/jq/releases/download/jq-${jq_version:?}/jq-linux-arm64" ;;
    Darwin-x86_64  | Darwin-amd64) \
      curl -fL -o "${HOME:?}/Applications/jq-${jq_version}/jq" \
        "https://github.com/jqlang/jq/releases/download/jq-${jq_version:?}/jq-macos-amd64" ;;
    Darwin-aarch64 | Darwin-arm64) \
      curl -fL -o "${HOME:?}/Applications/jq-${jq_version}/jq" \
        "https://github.com/jqlang/jq/releases/download/jq-${jq_version:?}/jq-macos-arm64" ;;
    *) echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ ERROR ] unsupported platform [$(uname -s)-$(uname -m)]" && false ;;
  esac && \
  chmod +x "${HOME:?}/Applications/jq-${jq_version}/jq" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] jq ${jq_version:?} installed."
fi && \
export PATH="${HOME:?}/Applications/jq-${1:?}:${PATH}"
