#!/usr/bin/env bash

apt-get update
apt-get install unzip zip -y
export SDKMAN_DIR="/opt/sdkman"
curl -s "https://get.sdkman.io" | bash
. /opt/sdkman/bin/sdkman-init.sh
sdk install java
sdk install kotlin
sdk install gradle