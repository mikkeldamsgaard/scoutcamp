#!/usr/bin/env bash

export SDKMAN_DIR="/opt/sdkman"
. /opt/sdkman/bin/sdkman-init.sh

cd backend
gradle distTar
cd ..
