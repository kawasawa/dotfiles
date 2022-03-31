#!/bin/bash
# 実行権限 (chmod +x) が無いとエラーになるので注意

# ------------------------------------------------------------------------------
# 定数
# ------------------------------------------------------------------------------

CHAR_RED='\033[31m'
CHAR_BOLD='\033[1m'
CHAR_RESET='\033[0m'
USAGE_ALERT_THRESHOLD=75

CC_USAGE_CACHE_FILE="/tmp/claude_oauth_usage_cache.json"
CC_USAGE_CACHE_TTL=120

# ------------------------------------------------------------------------------
# 関数
# ------------------------------------------------------------------------------

colorize_usage() {
  local usage="$1"
  if [ "$usage" -gt "$USAGE_ALERT_THRESHOLD" ] 2>/dev/null; then
    echo "${CHAR_RED}${CHAR_BOLD}${usage}%${CHAR_RESET}"
  else
    echo "${usage}%"
  fi
}

fetch_cc_usage() {
  local credentials=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
  local token=$(echo "$credentials" | jq -r '.claudeAiOauth.accessToken' 2>/dev/null)
  if [ -z "$token" ] || [ "$token" = "null" ]; then
    return
  fi

  local result=$(curl -s --max-time 3  \
    -H "Authorization: Bearer ${token}" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
  if echo "$result" | jq -e '.five_hour' >/dev/null 2>&1; then
    echo "$result" > "$CC_USAGE_CACHE_FILE"
  fi
}

# 指定のポーリング間隔を過ぎている場合はキャッシュを更新
cc_usage_cache_age=$(($(date +%s) - $(stat -f %m "$CC_USAGE_CACHE_FILE" 2>/dev/null || echo 0)))
if [ "$cc_usage_cache_age" -gt "$CC_USAGE_CACHE_TTL" ]; then
  fetch_cc_usage &
fi

# ------------------------------------------------------------------------------
# メイン
# ------------------------------------------------------------------------------

# input
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens')
used_context=$(echo "$input" | jq -r '.context_window.used_percentage // "0"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // ""')

# dir
dir_path=$(basename "$current_dir")
parent_dir_name=$(basename "$(dirname "$current_dir")")
if [ -n "$parent_dir_name" ] && [ "$parent_dir_name" != "/" ] && [ "$parent_dir_name" != "." ]; then
  dir_path="${parent_dir_name}/${dir_path}"
fi

# git
git_branch="-"
if [ -n "$current_dir" ]; then
  git_branch=$(git -C "$current_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-")
fi

# usage
cc_usage_session="-"
cc_usage_weekly="-"
if [ -f "$CC_USAGE_CACHE_FILE" ]; then
  session_util=$(jq -r '.five_hour.utilization // empty' "$CC_USAGE_CACHE_FILE" 2>/dev/null)
  if [ -n "$session_util" ]; then
    cc_usage_session="${session_util%.*}"
  fi
  weekly_util=$(jq -r '.seven_day.utilization // empty' "$CC_USAGE_CACHE_FILE" 2>/dev/null)
  if [ -n "$weekly_util" ]; then
    cc_usage_weekly="${weekly_util%.*}"
  fi
fi

# output
line1="󰚩 ${model} | 󰆼 $(colorize_usage "$used_context") |  5h:$(colorize_usage "$cc_usage_session") 7d:$(colorize_usage "$cc_usage_weekly")"
echo -e "$line1"
line2="󰝰 ${dir_path} | 󰘬 ${git_branch}"
# そのうち sandbox を判定できるようにしたい
# line2="󰝰 ${dir_path} | 󰘬 ${git_branch} | 󰒃 SANDBOX"
echo -e "$line2"
