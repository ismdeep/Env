#!/usr/bin/env bash

# Usage: bash pandoc.env.sh <pandoc-version>
#    <pandoc-version> example:
#      - 3.9
#
# https://github.com/jgm/pandoc/releases/download/3.9/pandoc-3.9-linux-amd64.tar.gz
# https://github.com/jgm/pandoc/releases/download/3.9/pandoc-3.9-linux-arm64.tar.gz
# https://github.com/jgm/pandoc/releases/download/3.9/pandoc-3.9-arm64-macOS.zip
# https://github.com/jgm/pandoc/releases/download/3.9/pandoc-3.9-x86_64-macOS.zip

if [ ! -f "${HOME:?}/Applications/pandoc-${1:?}/bin/pandoc" ]; then
  pandoc_version="${1:?}" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] pandoc ${pandoc_version:?} is installing ..." && \
  rm    -r -f "${HOME:?}/Applications/pandoc-${pandoc_version}/" && \
  # download and extract
  case $(uname -s)-$(uname -m) in
    Linux-x86_64   | Linux-amd64)  \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://github.com/jgm/pandoc/releases/download/${pandoc_version:?}/pandoc-${pandoc_version:?}-linux-amd64.tar.gz" && \
        tar -xzf "pandoc-${pandoc_version:?}-linux-amd64.tar.gz" && \
        rm -r -f "pandoc-${pandoc_version:?}-linux-amd64.tar.gz" && \
        mv       "pandoc-${pandoc_version:?}/" "pandoc-${pandoc_version:?}/");;
    Linux-aarch64  | Linux-arm64)  \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://github.com/jgm/pandoc/releases/download/${pandoc_version:?}/pandoc-${pandoc_version:?}-linux-arm64.tar.gz" && \
        tar -xzf "pandoc-${pandoc_version:?}-linux-arm64.tar.gz" && \
        rm -r -f "pandoc-${pandoc_version:?}-linux-arm64.tar.gz" && \
        mv       "pandoc-${pandoc_version:?}/" "pandoc-${pandoc_version:?}/");;
    Darwin-x86_64  | Darwin-amd64) \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://github.com/jgm/pandoc/releases/download/${pandoc_version:?}/pandoc-${pandoc_version:?}-x86_64-macOS.zip" && \
        unzip -q "pandoc-${pandoc_version:?}-x86_64-macOS.zip" && \
        rm -r -f "pandoc-${pandoc_version:?}-x86_64-macOS.zip" && \
        mv       "pandoc-${pandoc_version:?}-x86_64/" "pandoc-${pandoc_version:?}/");;
    Darwin-aarch64 | Darwin-arm64) \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://github.com/jgm/pandoc/releases/download/${pandoc_version:?}/pandoc-${pandoc_version:?}-arm64-macOS.zip" && \
        unzip -q "pandoc-${pandoc_version:?}-arm64-macOS.zip" && \
        rm -r -f "pandoc-${pandoc_version:?}-arm64-macOS.zip" && \
        mv       "pandoc-${pandoc_version:?}-arm64/" "pandoc-${pandoc_version:?}/");;
    *) echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ ERROR ] unsupported platform [$(uname -s)-$(uname -m)]" && false ;;
  esac && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] pandoc ${pandoc_version:?} installed."
fi && \
export PATH="${HOME:?}/Applications/pandoc-${1:?}/bin:${PATH}"
