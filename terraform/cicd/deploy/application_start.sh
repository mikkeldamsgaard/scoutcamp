#!/usr/bin/env bash

export SDKMAN_DIR="/opt/sdkman"
source /opt/sdkman/bin/sdkman-init.sh

frontend=`jq -r .frontend_url /etc/envinfo.json`
env=`jq -r .env /etc/envinfo.json`

export BACKEND_OPTS="-DENVIRONMENT=${env} -DFRONTEND_URL=${frontend} -DCONFIG_PROPERTIES=/etc/config.properties"

echo "Starting app"
nohup /opt/scoutcamp/backend/bin/backend > /var/log/app.log 2> /var/log/app-err.log &
echo "App started"

