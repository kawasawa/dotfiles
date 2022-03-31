#!/bin/bash
# 実行権限 (chmod +x) が無いとエラーになるので注意

# ------------------------------------------------------------------------------
# 定数
# ------------------------------------------------------------------------------

CHAR_RED='\033[31m'
CHAR_BOLD='\033[1m'
CHAR_RESET='\033[0m'

# 複数アカウント混在環境への対応
CC_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
if [ "$CC_CONFIG_DIR" = "$HOME/.claude" ]; then
  CC_CREDENTIALS="Claude Code-credentials"
else
  # デフォルト以外のアカウントは keychain サービス名に sha256(パス) 先頭8桁を付与
  CC_CREDENTIALS="Claude Code-credentials-$(printf '%s' "$CC_CONFIG_DIR" | shasum -a 256 | cut -c1-8)"
fi
# キャッシュは config dir 配下に出力しアカウント間の上書き防止
CC_USAGE_CACHE_FILE="${CC_CONFIG_DIR}/usage-cache.json"
CC_USAGE_CACHE_TTL=120
CC_USAGE_ALERT_THRESHOLD=75

# ------------------------------------------------------------------------------
# 関数
# ------------------------------------------------------------------------------

colorize_usage() {
  local usage="$1"
  if [ "$usage" -gt "$CC_USAGE_ALERT_THRESHOLD" ] 2>/dev/null; then
    echo "${CHAR_RED}${CHAR_BOLD}${usage}%${CHAR_RESET}"
  else
    echo "${usage}%"
  fi
}

# UTC の ISO8601 文字列をローカル時刻の指定フォーマットに変換
format_utc_to_local() {
  local iso="$1" fmt="$2"
  [ -z "$iso" ] && return
  # 小数秒・タイムゾーンオフセットを除去し UTC として epoch 化、ローカル時刻で整形
  local utc="${iso%%.*}"
  local epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$utc" +%s 2>/dev/null)
  [ -n "$epoch" ] && date -r "$epoch" "+$fmt" 2>/dev/null
}

fetch_cc_usage() {
  local credentials=$(security find-generic-password -s "$CC_CREDENTIALS" -w 2>/dev/null)
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
effort=$(echo "$input" | jq -r '.effort.level // empty')
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
cc_reset_session=""
cc_reset_weekly=""
if [ -f "$CC_USAGE_CACHE_FILE" ]; then
  session_util=$(jq -r '.five_hour.utilization // empty' "$CC_USAGE_CACHE_FILE" 2>/dev/null)
  if [ -n "$session_util" ]; then
    cc_usage_session="${session_util%.*}"
  fi
  weekly_util=$(jq -r '.seven_day.utilization // empty' "$CC_USAGE_CACHE_FILE" 2>/dev/null)
  if [ -n "$weekly_util" ]; then
    cc_usage_weekly="${weekly_util%.*}"
  fi
  # リセット日時 (5h は当日中なので時刻のみ、7d は日付付き)
  cc_reset_session=$(format_utc_to_local "$(jq -r '.five_hour.resets_at // empty' "$CC_USAGE_CACHE_FILE" 2>/dev/null)" "%H:%M")
  cc_reset_weekly=$(format_utc_to_local "$(jq -r '.seven_day.resets_at // empty' "$CC_USAGE_CACHE_FILE" 2>/dev/null)" "%m/%d %H:%M")
fi

# output
model_label="$model"
[ -n "$effort" ] && model_label="${model} (${effort})"
usage_session_label="$(colorize_usage "$cc_usage_session")"
[ -n "$cc_reset_session" ] && usage_session_label="${usage_session_label} (~${cc_reset_session})"
usage_weekly_label="$(colorize_usage "$cc_usage_weekly")"
[ -n "$cc_reset_weekly" ] && usage_weekly_label="${usage_weekly_label} (~${cc_reset_weekly})"
line1="󰚩 ${model_label} · 󰆼 ${used_context}% · 󰄉 ${usage_session_label} · 󰃭 ${usage_weekly_label}"
# 󰆼 $(colorize_usage "$used_context") |
line2="󰝰 ${dir_path} · 󰘬 ${git_branch}"
# そのうち sandbox を判定できるようにしたい
# line2="󰝰 ${dir_path} | 󰘬 ${git_branch} | 󰒃 SANDBOX"
echo -e "$line1"
echo -e "$line2"
