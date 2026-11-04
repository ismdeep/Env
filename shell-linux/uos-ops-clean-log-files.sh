#!/usr/bin/env bash

set -e
set -x

sudo rm -rfv /var/log/Xorg.*.log.old
sudo rm -rfv /var/log/Xorg.*.log.old.*
sudo rm -rfv /var/log/alternatives.log.*
sudo rm -rfv /var/log/alternatives.log.*.gz
sudo rm -rfv /var/log/auth.log.*
sudo rm -rfv /var/log/auth.log.*.gz
sudo rm -rfv /var/log/boot.log.*
sudo rm -rfv /var/log/daemon.log.*
sudo rm -rfv /var/log/daemon.log.*.gz
sudo rm -rfv /var/log/debug.*
sudo rm -rfv /var/log/debug.*.gz
sudo rm -rfv /var/log/dpkg.log.*
sudo rm -rfv /var/log/dpkg.log.*.gz
sudo rm -rfv /var/log/journal/*/system@*.journal
sudo rm -rfv /var/log/journal/*/user-*@*.journal
sudo rm -rfv /var/log/syslog.*
sudo rm -rfv /var/log/syslog.*.gz
sudo rm -rfv /var/log/uos/uos-license-agent/uos-license-agent.log.*
sudo rm -rfv /var/log/uos/uosdeviceh/uosdeviceh.log.*
sudo rm -rfv /var/log/user.log.*