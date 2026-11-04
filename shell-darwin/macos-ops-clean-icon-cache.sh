#!/usr/bin/env bash

sudo rm -rf /Library/Caches/com.apple.iconservices.store
sudo find /private/var/folders/ -name com.apple.iconservices -exec rm -rf {} \;
killall Finder
killall Dock
