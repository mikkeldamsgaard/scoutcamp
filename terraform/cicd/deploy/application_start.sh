#!/usr/bin/env bash

export SDKMAN_DIR="/opt/sdkman"
source /opt/sdkman/bin/sdkman-init.sh

echo "Starting app"
nohup /opt/scoutcamp/backend/bin/backend > /var/log/app.log 2> /var/log/app-err.log &
echo "App started"

