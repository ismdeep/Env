#!/usr/bin/env bash

set -e

tmpdir="${HOME:?}/tmp.$(TZ=Asia/Shanghai date +%Y%m%d.%H%M%S).$(openssl rand -hex 2)"
mkdir -p "${tmpdir}"
echo -n "${tmpdir}"
