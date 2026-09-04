#!/bin/sh
set -eu

/bin/sh /lzcapp/pkg/content/runtime/prepare-config.sh
exec python3 main.py
