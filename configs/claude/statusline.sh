#!/bin/bash

# ------------------------------------------------------------------------------
# 定数
# ------------------------------------------------------------------------------

USAGE_CACHE_FILE="/tmp/claude_oauth_usage_cache.json"
USAGE_CACHE_TTL=300

# ------------------------------------------------------------------------------
# 関数
# ------------------------------------------------------------------------------

fetch_usage() {
  local credentials token result
  credentials=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
  token=$(echo "$credentials" | jq -r '.claudeAiOauth.accessToken' 2>/dev/null)
  if [ -z "$token" ] || [ "$token" = "null" ]; then
    return
  fi

  result=$(curl -s --max-time 3 "https://api.anthropic.com/api/oauth/usage" \
    -H "Authorization: Bearer ${token}" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "User-Agent: claude-code/2.0.31" \
    -H "Accept: application/json" 2>/dev/null)
  if echo "$result" | jq -e '.five_hour' >/dev/null 2>&1; then
    echo "$result" > "$USAGE_CACHE_FILE"
  fi
}

# ------------------------------------------------------------------------------
# メイン
# ------------------------------------------------------------------------------

# stdin
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens')
used_context=$(echo "$input" | jq -r '.context_window.used_percentage // "0"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // ""')
dir_name=$(basename "$current_dir")

# Git
git_branch=""
if [ -n "$current_dir" ]; then
  git_branch=$(git -C "$current_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# usage
cache_age=$(($(date +%s) - $(stat -f %m "$USAGE_CACHE_FILE" 2>/dev/null || echo 0)))
if [ "$cache_age" -gt "$USAGE_CACHE_TTL" ]; then
  fetch_usage &
fi
session_pct="-"
weekly_pct="-"
if [ -f "$USAGE_CACHE_FILE" ]; then
  session_util=$(jq -r '.five_hour.utilization // empty' "$USAGE_CACHE_FILE" 2>/dev/null)
  if [ -n "$session_util" ]; then
    session_pct="${session_util%.*}"
  fi

  weekly_util=$(jq -r '.seven_day.utilization // empty' "$USAGE_CACHE_FILE" 2>/dev/null)
  if [ -n "$weekly_util" ]; then
    weekly_pct="${weekly_util%.*}"
  fi
fi

# output
line1="󰚩 ${model} | 󰆼 ${used_context}% |  5h ${session_pct}% / 7d ${weekly_pct}%"
echo "$line1"
line2="󰝰 ${dir_name} | 󰘬 ${git_branch}"
echo "$line2"
