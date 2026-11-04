#!/usr/bin/env bash

# Usage: source ipfs.env.sh <ipfs-version>
#    <ipfs-version> example:
#      - v0.39.0
#
# https://github.com/ipfs/kubo/releases/download/v0.39.0/kubo_v0.39.0_linux-amd64.tar.gz
# https://github.com/ipfs/kubo/releases/download/v0.39.0/kubo_v0.39.0_linux-arm64.tar.gz
# https://github.com/ipfs/kubo/releases/download/v0.39.0/kubo_v0.39.0_darwin-amd64.tar.gz
# https://github.com/ipfs/kubo/releases/download/v0.39.0/kubo_v0.39.0_darwin-arm64.tar.gz

if [ ! -f "${HOME:?}/Applications/ipfs-${1:?}/ipfs" ]; then
  ipfs_version="${1:?}" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] kubo ${ipfs_version:?} is installing ..." && \
  tmp_dir="${HOME:?}/Applications/.tmp-ipfs-${ipfs_version}" && \
  rm    -r -f "${tmp_dir}" && \
  mkdir -p "${tmp_dir}" && \
  # download and extract
  curl_opts=(-fL) && \
  [ -n "${CURL_PROXY}" ] && curl_opts+=(-x "${CURL_PROXY}") && \
  case $(uname -s)-$(uname -m) in
    Linux-x86_64   | Linux-amd64)  \
      curl "${curl_opts[@]}" "https://github.com/ipfs/kubo/releases/download/${ipfs_version:?}/kubo_${ipfs_version}_linux-amd64.tar.gz" | \
      tar -xz -C "${tmp_dir}" --strip-components=1 ;;
    Linux-aarch64  | Linux-arm64)  \
      curl "${curl_opts[@]}" "https://github.com/ipfs/kubo/releases/download/${ipfs_version:?}/kubo_${ipfs_version}_linux-arm64.tar.gz" | \
      tar -xz -C "${tmp_dir}" --strip-components=1 ;;
    Darwin-x86_64  | Darwin-amd64) \
      curl "${curl_opts[@]}" "https://github.com/ipfs/kubo/releases/download/${ipfs_version:?}/kubo_${ipfs_version}_darwin-amd64.tar.gz" | \
      tar -xz -C "${tmp_dir}" --strip-components=1 ;;
    Darwin-aarch64 | Darwin-arm64) \
      curl "${curl_opts[@]}" "https://github.com/ipfs/kubo/releases/download/${ipfs_version:?}/kubo_${ipfs_version}_darwin-arm64.tar.gz" | \
      tar -xz -C "${tmp_dir}" --strip-components=1 ;;
    *) echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ ERROR ] unsupported platform [$(uname -s)-$(uname -m)]" && false ;;
  esac && \
  rm -r -f "${HOME:?}/Applications/ipfs-${ipfs_version}" && \
  mv "${tmp_dir}" "${HOME:?}/Applications/ipfs-${ipfs_version}" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] kubo ${ipfs_version:?} installed."
fi && \
export PATH="${HOME:?}/Applications/ipfs-${1:?}:${PATH}"
