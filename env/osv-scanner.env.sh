#!/usr/bin/env bash

# Usage: bash osv-scanner.env.sh <osv-scanner-version>
#    <osv-scanner-version> example:
#      - v2.3.3
#
# https://github.com/google/osv-scanner/releases/download/v2.3.3/osv-scanner_linux_amd64
# https://github.com/google/osv-scanner/releases/download/v2.3.3/osv-scanner_linux_arm64
# https://github.com/google/osv-scanner/releases/download/v2.3.3/osv-scanner_darwin_amd64
# https://github.com/google/osv-scanner/releases/download/v2.3.3/osv-scanner_darwin_arm64

if [ ! -f "${HOME:?}/Applications/osv-scanner-${1:?}/osv-scanner" ]; then
  osv_scanner_version="${1:?}" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] osv-scanner ${osv_scanner_version:?} is installing ..." && \
  rm    -r -f "${HOME:?}/Applications/osv-scanner-${osv_scanner_version}/" && \
  mkdir -p "${HOME:?}/Applications/osv-scanner-${osv_scanner_version}/" && \
  case $(uname -s)-$(uname -m) in
    Linux-x86_64   | Linux-amd64)  \
      curl -fL -o "${HOME:?}/Applications/osv-scanner-${osv_scanner_version}/osv-scanner" \
        "https://github.com/google/osv-scanner/releases/download/${osv_scanner_version:?}/osv-scanner_linux_amd64" ;;
    Linux-aarch64  | Linux-arm64)  \
      curl -fL -o "${HOME:?}/Applications/osv-scanner-${osv_scanner_version}/osv-scanner" \
        "https://github.com/google/osv-scanner/releases/download/${osv_scanner_version:?}/osv-scanner_linux_arm64" ;;
    Darwin-x86_64  | Darwin-amd64) \
      curl -fL -o "${HOME:?}/Applications/osv-scanner-${osv_scanner_version}/osv-scanner" \
        "https://github.com/google/osv-scanner/releases/download/${osv_scanner_version:?}/osv-scanner_darwin_amd64" ;;
    Darwin-aarch64 | Darwin-arm64) \
      curl -fL -o "${HOME:?}/Applications/osv-scanner-${osv_scanner_version}/osv-scanner" \
        "https://github.com/google/osv-scanner/releases/download/${osv_scanner_version:?}/osv-scanner_darwin_arm64" ;;
    *) echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ ERROR ] unsupported platform [$(uname -s)-$(uname -m)]" && false ;;
  esac && \
  chmod +x "${HOME:?}/Applications/osv-scanner-${osv_scanner_version}/osv-scanner" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] osv-scanner ${osv_scanner_version:?} installed."
fi && \
export PATH="${HOME:?}/Applications/osv-scanner-${1:?}:${PATH}"
