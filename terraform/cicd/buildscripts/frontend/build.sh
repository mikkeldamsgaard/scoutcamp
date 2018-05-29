#!/usr/bin/env bash

set -v -e

cd frontend

PATH="$PATH":"~/.pub-cache/bin"
/usr/lib/dart/bin/pub global activate pub_mediator
mediator

/usr/lib/dart/bin/pub get -v
/usr/lib/dart/bin/pub build --mode=release --output=build
cd ..

