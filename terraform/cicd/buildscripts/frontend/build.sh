#!/usr/bin/env bash

cd frontend
/usr/lib/dart/bin/pub get
/usr/lib/dart/bin/pub build --mode=release --output=build
cd ..

