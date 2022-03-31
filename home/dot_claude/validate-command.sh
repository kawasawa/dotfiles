#!/bin/bash
# 実行権限 (chmod +x) が無いとエラーになるので注意

# ブロック対象のコマンド一覧
INVALID_PATTERNS=(
  'rm -rf',
  'sudo',
  'gh auth token'
)

# コマンド検証
COMMAND=$(jq -r '.tool_input.command' < /dev/stdin)
for pattern in "${INVALID_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -q "$pattern"; then
    echo "Blocked: '$pattern' commands are not allowed" >&2
    exit 2  # ブロック
  fi
done

exit 0