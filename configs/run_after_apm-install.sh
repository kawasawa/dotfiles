#!/bin/sh
set -euo pipefail

if type apm > /dev/null 2>&1; then
  apm install --global --update
  apm compile --global
fi
