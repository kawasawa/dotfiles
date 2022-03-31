#!/bin/sh
set -euo pipefail

echo "=== run_after_apm-install ==="

if ! type apm > /dev/null 2>&1; then
    echo "apm not installed, skipped"
    exit 1
fi

# apm の更新は config 起点ではなくリポジトリ側次第なので毎回実行
apm install --update --global
apm compile --global
