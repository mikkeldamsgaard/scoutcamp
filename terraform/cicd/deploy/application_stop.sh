#!/usr/bin/env bash

ps -e | grep java | awk '{print $1}' | xargs kill -9