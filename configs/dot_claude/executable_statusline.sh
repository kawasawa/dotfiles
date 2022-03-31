#!/bin/bash
# 実行権限 (chmod +x) が無いとエラーになるので注意

# ------------------------------------------------------------------------------
# 定数
# ------------------------------------------------------------------------------

CHAR_RED='\033[31m'
CHAR_BOLD='\033[1m'
CHAR_RESET='\033[0m'

CC_USAGE_ALERT_THRESHOLD=75

# レートリミットに関する情報を退避するファイル
CC_RATE_LIMITS_CACHE_FILE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/statusline-cache.json"

# ------------------------------------------------------------------------------
# 関数
# ------------------------------------------------------------------------------

# 使用量がアラート閾値に達していれば警告色でカラーリングする
colorize_usage() {
  local usage="$1"
  if [ "$usage" -gt "$CC_USAGE_ALERT_THRESHOLD" ] 2>/dev/null; then
    echo "${CHAR_RED}${CHAR_BOLD}${usage}%${CHAR_RESET}"
  else
    echo "${usage}%"
  fi
}

# Unix epoch 秒をローカル時刻の指定フォーマットに変換
format_epoch_to_local() {
  local epoch="$1" fmt="$2"
  [ -z "$epoch" ] && return
  date -r "$epoch" "+$fmt" 2>/dev/null
}

# ------------------------------------------------------------------------------
# メイン
# ------------------------------------------------------------------------------

# input
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name')
effort=$(echo "$input" | jq -r '.effort.level // empty')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // ""')
usage_context=$(echo "$input" | jq -r '.context_window.used_percentage // "0"')

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
#   rate_limits は claude.ai Pro/Max のみ
#   セッション初回の API 応答前とリセット時刻を過ぎた枠は欠落するためセッション間で共有するキャッシュを作り補う
#   枠ごとに入力とキャッシュの新しい方を採用し、リセット時刻を過ぎた枠は除外
#   同一枠内では使用率が単調増加し、新しい枠ほど resets_at が大きいため [resets_at, used_percentage] の辞書順で比較
#   (待機中の別セッションが古い値で再描画しても巻き戻らない)
cached_rate_limits=$(jq -c 'objects' "$CC_RATE_LIMITS_CACHE_FILE" 2>/dev/null)
rate_limits=$(echo "$input" | jq -c --argjson now "$(date +%s)" --argjson cached "${cached_rate_limits:-null}" '
  def newer($a; $b):
    if $a == null then $b elif $b == null then $a
    elif [$a.resets_at, $a.used_percentage] >= [$b.resets_at, $b.used_percentage] then $a else $b end;
  (.rate_limits // {}) as $r | ($cached // {}) as $c
  | {five_hour: newer($r.five_hour; $c.five_hour), seven_day: newer($r.seven_day; $c.seven_day)}
  | with_entries(select(.value.resets_at > $now))')
if [ -n "$rate_limits" ] && [ "$rate_limits" != "$cached_rate_limits" ]; then
  # 他セッションが書き込み途中のファイルを読まないよう一時ファイル経由で置換
  echo "$rate_limits" > "${CC_RATE_LIMITS_CACHE_FILE}.$$" && mv -f "${CC_RATE_LIMITS_CACHE_FILE}.$$" "$CC_RATE_LIMITS_CACHE_FILE"
fi
cc_usage_session=$(echo "$rate_limits" | jq -r '.five_hour.used_percentage | floor? // "-"')
cc_usage_weekly=$(echo "$rate_limits" | jq -r '.seven_day.used_percentage | floor? // "-"')
# リセット日時 (5h は当日中なので時刻のみ、7d は日付付き)
cc_reset_session=$(format_epoch_to_local "$(echo "$rate_limits" | jq -r '.five_hour.resets_at // empty')" "%H:%M")
cc_reset_weekly=$(format_epoch_to_local "$(echo "$rate_limits" | jq -r '.seven_day.resets_at // empty')" "%m/%d %H:%M")

# output
label_model="$model"
[ -n "$effort" ] && label_model="${model} (${effort})"
label_context="$(colorize_usage "$usage_context")"
label_session="$(colorize_usage "$cc_usage_session")"
[ -n "$cc_reset_session" ] && label_session="${label_session} (~${cc_reset_session})"
label_weekly="$(colorize_usage "$cc_usage_weekly")"
[ -n "$cc_reset_weekly" ] && label_weekly="${label_weekly} (~${cc_reset_weekly})"
line1="󰚩 ${label_model} · 󰆼 ${label_context} · 󰄉 ${label_session} · 󰃭 ${label_weekly}"
line2="󰝰 ${dir_path} · 󰘬 ${git_branch}"
# そのうち sandbox を判定できるようにしたい
# line2="󰝰 ${dir_path} | 󰘬 ${git_branch} | 󰒃 SANDBOX"
echo -e "$line1"
echo -e "$line2"
