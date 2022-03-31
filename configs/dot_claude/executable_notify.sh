#!/bin/bash
# 実行権限 (chmod +x) が無いとエラーになるので注意

# 入力内容を取得
input=$(cat 2>/dev/null) || exit 0
[[ -n "$input" ]] || exit 0

# エスケープ処理
escape() {
  # AppleScript の構文エラーを回避するため \ と " をエスケープ
  local text=${1//\\/\\\\}
  printf '%s' "${text//\"/\\\"}"
}

# 通知処理
notify() {
  local title="$1"
  local message="$2"
  local project="$3"
  local sound="$4"

  osascript -e "display notification \"$(escape "$message")\" with title \"$(escape "$title")\" subtitle \"$(escape "$project")\""
  if [[ -n "$sound" ]]; then
    afplay "/System/Library/Sounds/$sound.aiff"
  fi
}

# 通知タイプ分類
notification_type=$(echo "$input" | jq -r '.notification_type // "unknown"')
case "$notification_type" in
  # 操作待ち
  # - permission_prompt: ツールの使用許可を求めたとき
  # - worker_permission_prompt: teammate/worker がツール許可/NWアクセス許可を求めたとき
  # - agent_needs_input: サブエージェント/teammate が入力待ちになったとき
  # - elicitation_dialog: MCPサーバが入力要求ダイアログを開いたとき
  # - elicitation_url_dialog: MCPサーバが入力要求ダイアログを開いたとき (ブラウザでリンクを開かせる形式)
  # - quota_auto_resume_stale: 使用上限リセット後、自動再開時刻を過ぎていたとき (スリープ中に跨いだ場合など)
  "permission_prompt" | \
  "worker_permission_prompt" | \
  "agent_needs_input" | \
  "elicitation_dialog" | \
  "elicitation_url_dialog" | \
  "quota_auto_resume_stale")
    sound="Ping"
    ;;

  # 待機
  # - idle_prompt: 入力が無いまま一定時間経過 (see: messageIdleNotifThresholdMs)
  # - push_notification: ユーザ不在時の汎用通知
  "idle_prompt" | \
  "push_notification")
    sound="Pop"
    ;;

  # 開始
  # - quota_auto_resume_fired: 使用上限リセット後、自動再開されたとき
  # - computer_use_enter: "computer use" でPC操作を開始したとき
  "quota_auto_resume_fired" | \
  "computer_use_enter")
    sound="Funk"
    ;;

  # 経過
  # - auth_success: ログイン成功時
  # - elicitation_response: MCPサーバが入力要求の応答を確認したとき
  # - elicitation_complete: MCPサーバが elicitation_url の完了を確認したとき (elicitation_response の後)
  # - computer_use_exit: "computer use" でPC操作を終了したとき
  "auth_success" | \
  "elicitation_response" | \
  "elicitation_complete" | \
  "computer_use_exit")
    sound="Purr"
    ;;

  # 完了
  # - agent_completed: サブエージェントの作業終了時
  # - stop: (自前実装) Stop フック発火時
  "agent_completed" | \
  "stop")
    sound="Glass"
    ;;

  # 上記以外
  # - quota_auto_resume_disabled: 自動再開が無効化/停止したとき (手動off/リセットが24時間より先/継続がモデル到達前にブロック/上限の繰り返しヒット)
  # - そのほか: 通知タイプはバージョンアップで変わり得るため未知のものは無音通知
  "quota_auto_resume_disabled" | \
  *)
    sound=""
    ;;
esac

# 通知実行
title="Claude Code"
message=$(echo "$input" | jq -r '.message // empty')
project=$(basename "$(echo "$input" | jq -r '.cwd // empty')")
notify "$title" "${message:-$notification_type}" "$project" "$sound"

exit 0
