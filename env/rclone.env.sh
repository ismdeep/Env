#!/usr/bin/env bash

# Usage: bash rclone.env.sh <rclone-version>
#    <rclone-version> example:
#      - v1.73.0
#
# https://github.com/rclone/rclone/releases/download/v1.73.0/rclone-v1.73.0-osx-amd64.zip
# https://github.com/rclone/rclone/releases/download/v1.73.0/rclone-v1.73.0-osx-arm64.zip
# https://github.com/rclone/rclone/releases/download/v1.73.0/rclone-v1.73.0-linux-amd64.zip
# https://github.com/rclone/rclone/releases/download/v1.73.0/rclone-v1.73.0-linux-arm64.zip

if [ ! -f "${HOME:?}/Applications/rclone-${1:?}/rclone" ]; then
  rclone_version="${1:?}" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] rclone ${rclone_version:?} is installing ..." && \
  rm    -r -f "${HOME:?}/Applications/rclone-${rclone_version}/" && \
  # download and extract
  case $(uname -s)-$(uname -m) in
    Linux-x86_64   | Linux-amd64)  \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://github.com/rclone/rclone/releases/download/${rclone_version:?}/rclone-${rclone_version:?}-linux-amd64.zip" && \
        unzip -q "rclone-${rclone_version:?}-linux-amd64.zip" && \
        rm -r -f "rclone-${rclone_version:?}-linux-amd64.zip" && \
        mv       "rclone-${rclone_version:?}-linux-amd64/" "rclone-${rclone_version:?}/") ;;
    Linux-aarch64  | Linux-arm64)  \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://github.com/rclone/rclone/releases/download/${rclone_version:?}/rclone-${rclone_version:?}-linux-arm64.zip" && \
        unzip -q "rclone-${rclone_version:?}-linux-arm64.zip" && \
        rm -r -f "rclone-${rclone_version:?}-linux-arm64.zip" && \
        mv       "rclone-${rclone_version:?}-linux-arm64/" "rclone-${rclone_version:?}/") ;;
    Darwin-x86_64  | Darwin-amd64) \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://github.com/rclone/rclone/releases/download/${rclone_version:?}/rclone-${rclone_version:?}-osx-amd64.zip" && \
        unzip -q "rclone-${rclone_version:?}-osx-amd64.zip" && \
        rm -r -f "rclone-${rclone_version:?}-osx-amd64.zip" && \
        mv       "rclone-${rclone_version:?}-osx-amd64/" "rclone-${rclone_version:?}/") ;;
    Darwin-aarch64 | Darwin-arm64) \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://github.com/rclone/rclone/releases/download/${rclone_version:?}/rclone-${rclone_version:?}-osx-arm64.zip" && \
        unzip -q "rclone-${rclone_version:?}-osx-arm64.zip" && \
        rm -r -f "rclone-${rclone_version:?}-osx-arm64.zip" && \
        mv       "rclone-${rclone_version:?}-osx-arm64/" "rclone-${rclone_version:?}/") ;;
    *) echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ ERROR ] unsupported platform [$(uname -s)-$(uname -m)]" && false ;;
  esac && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] rclone ${rclone_version:?} installed."
fi && \
export PATH="${HOME:?}/Applications/rclone-${1:?}:${PATH}"
