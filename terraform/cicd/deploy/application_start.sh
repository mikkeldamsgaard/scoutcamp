#!/usr/bin/env bash

source /opt/sdkman/bin/sdkman-init.sh

echo "Starting app"
nohup /opt/scoutcamp/backend/bin/backend > /var/log/app.log 2> /var/log/app-err.log &
echo "App started"

