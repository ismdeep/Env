#!/usr/bin/env bash

pgrep 'Cloudflare WARP' | xargs sudo kill -9
echo 'Processes killed.'

echo "检查系统中 Cloudflare 进程："
pgrep 'Cloudflare WARP'
