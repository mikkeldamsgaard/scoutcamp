#!/usr/bin/env bash


apt-get update
apt-get install apt-transport-https -y
sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'

sudo apt-get update
sudo apt-get install dart -y

sudo apt-get install python-pip -y
pip install j2