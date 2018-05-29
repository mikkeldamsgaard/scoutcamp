#!/usr/bin/env bash

set -v -e

cd frontend

j2 lib/src/config/vars.template.dart > lib/src/config/vars.dart
cat lib/src/config/vars.dart

PATH="$PATH":"~/.pub-cache/bin"
/usr/lib/dart/bin/pub global activate pub_mediator
mediator

/usr/lib/dart/bin/pub get
/usr/lib/dart/bin/pub build --mode=release --output=build
cd ..

