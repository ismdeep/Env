#!/usr/bin/env bash

# Usage: bash chromedriver.env.sh <chromedriver-version>
#    <chromedriver-version> example:
#      - 145.0.7632.67
#
# https://storage.googleapis.com/chrome-for-testing-public/145.0.7632.67/linux64/chromedriver-linux64.zip
# https://storage.googleapis.com/chrome-for-testing-public/145.0.7632.67/mac-x64/chromedriver-mac-x64.zip
# https://storage.googleapis.com/chrome-for-testing-public/145.0.7632.67/mac-arm64/chromedriver-mac-arm64.zip

if [ ! -f "${HOME:?}/Applications/chromedriver-${1:?}/chromedriver" ]; then
  chromedriver_version="${1:?}" && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] chromedriver ${chromedriver_version:?} is installing ..." && \
  rm    -r -f "${HOME:?}/Applications/chromedriver-${chromedriver_version}/" && \
  # download and extract
  case $(uname -s)-$(uname -m) in
    Linux-x86_64   | Linux-amd64)  \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://storage.googleapis.com/chrome-for-testing-public/${chromedriver_version:?}/linux64/chromedriver-linux64.zip" && \
        unzip -q "chromedriver-linux64.zip" && \
        rm -r -f "chromedriver-linux64.zip" && \
        mv       "chromedriver-linux64/" "chromedriver-${chromedriver_version:?}/") ;;
    Darwin-x86_64  | Darwin-amd64) \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://storage.googleapis.com/chrome-for-testing-public/${chromedriver_version:?}/mac-x64/chromedriver-mac-x64.zip" && \
        unzip -q "chromedriver-mac-x64.zip" && \
        rm -r -f "chromedriver-mac-x64.zip" && \
        mv       "chromedriver-mac-x64/" "chromedriver-${chromedriver_version:?}/") ;;
    Darwin-aarch64 | Darwin-arm64) \
      (\
        cd "${HOME}/Applications/" && \
        curl -fLO "https://storage.googleapis.com/chrome-for-testing-public/${chromedriver_version:?}/mac-arm64/chromedriver-mac-arm64.zip" && \
        unzip -q "chromedriver-mac-arm64.zip" && \
        rm -r -f "chromedriver-mac-arm64.zip" && \
        mv       "chromedriver-mac-arm64/" "chromedriver-${chromedriver_version:?}/") ;;
    *) echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ ERROR ] unsupported platform [$(uname -s)-$(uname -m)]" && false ;;
  esac && \
  echo "$(date '+%Y-%m-%d %H:%M:%S %z') [ INFO ] chromedriver ${chromedriver_version:?} installed."
fi && \
export PATH="${HOME:?}/Applications/chromedriver-${1:?}:${PATH}"
