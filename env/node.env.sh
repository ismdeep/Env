#!/usr/bin/env bash

if [ ! -f "${HOME:?}/Applications/node-${1:?}/bin/node" ]; then
  (command -v pv  >/dev/null 2>&1 || (echo "$(date -R) [ ERROR ] command required: pv"  && false)) && \
  (command -v xz  >/dev/null 2>&1 || (echo "$(date -R) [ ERROR ] command required: xz"  && false)) && \
  (command -v tar >/dev/null 2>&1 || (echo "$(date -R) [ ERROR ] command required: tar" && false)) && \
  node_version="${1:?}" && \
  echo "$(date -R) [ INFO ] nodejs ${node_version} is installing ..." && \
  rm -r -f "${HOME}/Applications/node-${1:?}/" && \
  file_name="" && \
  case $(uname -s)-$(uname -m) in
    Linux-amd64|Linux-x86_64)    file_name="node-${node_version}-linux-x64"    ;;
    Linux-arm64|Linux-aarch64)   file_name="node-${node_version}-linux-arm64"  ;;
    Darwin-amd64|Darwin-x86_64)  file_name="node-${node_version}-darwin-x64"   ;;
    Darwin-arm64|Darwin-aarch64) file_name="node-${node_version}-darwin-arm64" ;;
    *) echo "ERROR: unsupported platform. [$(uname -s)-$(uname -m)]" && false  ;;
  esac && \
  cd "${HOME}/Applications/" && \
  (
    cd "${HOME}/Applications/" && \
    curl -fLO "https://nodejs.org/dist/${node_version}/${file_name}.tar.xz" && \
    pv "${file_name}.tar.xz" | xz -cdk - | tar -x && \
    mv "${file_name}" "node-${node_version}" && \
    rm "${file_name}.tar.xz" && \
    echo "$(date -R) [ INFO ] nodejs ${node_version} installed."
  )
fi && \
export PATH="${HOME}/Applications/node-${1:?}/bin:${PATH}"
