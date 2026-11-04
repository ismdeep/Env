#!/usr/bin/env bash

set -x

sudo pfctl -sr
sudo pfctl -F all -f /etc/pf.conf
sudo pfctl -e
sudo netstat -rn
sudo route -n flush

{ set +x; } >/dev/null 2>&1

echo "请断开网络并重新连接。"
