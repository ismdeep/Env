#!/usr/bin/env bash

# Usage: bash go.env.sh <go-version>
#    <go-version> example:
#      - go1.20.12

if [ ! -f "${HOME:?}/Applications/${1:?}/go/bin/go" ]; then
  go_version="${1:?}" && \
  echo "$(date -R) [ INFO ] ${go_version:?} is installing ..." && \
  rm    -r -f "${HOME:?}/Applications/${go_version:?}/" && \
  mkdir -p    "${HOME:?}/Applications/${go_version:?}/" && \
  # get file name
  file_name="" && \
  case $(uname -s)-$(uname -m) in
    Linux-x86_64   | Linux-amd64)  file_name="${go_version}.linux-amd64.tar.gz"  ;;
    Linux-aarch64  | Linux-arm64)  file_name="${go_version}.linux-arm64.tar.gz"  ;;
    Darwin-x86_64  | Darwin-amd64) file_name="${go_version}.darwin-amd64.tar.gz" ;;
    Darwin-aarch64 | Darwin-arm64) file_name="${go_version}.darwin-arm64.tar.gz" ;;
    *) echo "ERROR: unsupported platform [$(uname -s)-$(uname -m)]" && false ;;
  esac && \
  # download and extract
  (
    cd "${HOME}/Applications/${go_version}/" && \
    curl \
      --fail \
      --location \
      --output "${file_name}" \
      "https://dl.google.com/go/${file_name}" && \
    echo "$(date -R) [ INFO ] ${go_version} downloaded at ${HOME}/Applications/${go_version}/${file_name}" && \
    tar -zxf "${file_name}"
  ) && \
  mkdir -p "${HOME}/Applications/${go_version}/path/" && \
  mkdir -p "${HOME}/Applications/${go_version}/cache/" && \
  echo "$(date -R) [ INFO ] ${go_version} installed."
fi && \
export GOROOT="${HOME}/Applications/${1:?}/go" && \
export GOPATH="${HOME}/Applications/${1:?}/path" && \
export GOCACHE="${HOME}/Applications/${1:?}/cache" && \
export PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
