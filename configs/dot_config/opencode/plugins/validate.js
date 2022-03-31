// bash ツール実行前のセキュリティ検証
//
// 判定ロジックは Claude Code の PreToolUse フック (~/.claude/validate.sh) に一元化し、本プラグインは入出力の変換のみを担う
//   入力: PreToolUse と同形式の JSON を stdin へ渡す
//   出力: 終了コード 2 のみをブロックとし、stderr の通知文を例外としてモデルへ返す
//   それ以外 (許可・フック欠落・実行失敗) は validate.sh と同じく fail-open
//   ※ ブロックのログは ~/.claude/validate.log に Claude Code と共用で記録される
// tool.execute.before は permission の確認より前に呼ばれる

import { homedir } from "node:os"
import { join } from "node:path"

const HOOK = join(homedir(), ".claude", "validate.sh")

/** @type {import("@opencode-ai/plugin").Plugin} */
export const Validate = async ({ $ }) => ({
  "tool.execute.before": async (input, output) => {
    if (input.tool !== "bash") return
    const payload = JSON.stringify({ tool_name: "Bash", tool_input: { command: output.args.command } })
    const result = await $`${HOOK} < ${new Response(payload)}`.nothrow().quiet()
    if (result.exitCode === 2) throw new Error(result.stderr.toString().trim())
  },
})
