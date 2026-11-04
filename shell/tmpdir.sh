#!/usr/bin/env bash

set -e

tmpdir="${HOME}/.x98/tmp/$(date +%Y%m%d%H%M%S)-$(openssl rand -hex 32)"
mkdir -p "${tmpdir:?}/"
echo "${tmpdir}"
