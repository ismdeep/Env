#!/usr/bin/env bash

# Usage: bash yq.env.sh <yq-version>
#    <yq-version> example:
#      - v4.52.2
#
# https://github.com/mikefarah/yq/releases/download/v4.52.2/yq_linux_amd64
# https://github.com/mikefarah/yq/releases/download/v4.52.2/yq_linux_arm64
# https://github.com/mikefarah/yq/releases/download/v4.52.2/yq_darwin_amd64
# https://github.com/mikefarah/yq/releases/download/v4.52.2/yq_darwin_arm64

if [ ! -f "${HOME:?}/Applications/yq-${1:?}/yq" ]; then
  yq_version="${1:?}" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] yq ${yq_version:?} is installing ..." && \
  rm    -r -f "${HOME:?}/Applications/yq-${yq_version}/" && \
  mkdir -p "${HOME:?}/Applications/yq-${yq_version}/" && \
  case $(uname -s)-$(uname -m) in
    Linux-x86_64   | Linux-amd64)  \
      curl -fL -o "${HOME:?}/Applications/yq-${yq_version}/yq" \
        "https://github.com/mikefarah/yq/releases/download/${yq_version:?}/yq_linux_amd64" ;;
    Linux-aarch64  | Linux-arm64)  \
      curl -fL -o "${HOME:?}/Applications/yq-${yq_version}/yq" \
        "https://github.com/mikefarah/yq/releases/download/${yq_version:?}/yq_linux_arm64" ;;
    Darwin-x86_64  | Darwin-amd64) \
      curl -fL -o "${HOME:?}/Applications/yq-${yq_version}/yq" \
        "https://github.com/mikefarah/yq/releases/download/${yq_version:?}/yq_darwin_amd64" ;;
    Darwin-aarch64 | Darwin-arm64) \
      curl -fL -o "${HOME:?}/Applications/yq-${yq_version}/yq" \
        "https://github.com/mikefarah/yq/releases/download/${yq_version:?}/yq_darwin_arm64" ;;
    *) echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ ERROR ] unsupported platform [$(uname -s)-$(uname -m)]" && false ;;
  esac && \
  chmod +x "${HOME:?}/Applications/yq-${yq_version}/yq" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] yq ${yq_version:?} installed."
fi && \
export PATH="${HOME:?}/Applications/yq-${1:?}:${PATH}"
