---
applyTo: "**"
description: "タスクに応じた最適なMCPサーバの使用規約"
---

# MCP サーバ利用規約

タスクに応じて以下の MCP サーバの使用を優先する。

## 推奨 MCP サーバ

### Context7 MCP: ドキュメント/パッケージ調査

#### 用途

- 未知のパッケージの理解
- 最新ベストプラクティス、機能、使用方法の調査

#### ツール

1. `resolve-library-id` で ID 取得
2. `get-library-docs` でドキュメント取得

### Serena MCP: コード解析/構造理解

#### 用途

- 既存コードの構造理解
- シンボル検索 (クラス、関数等)
- 参照関係調査
- 変更範囲特定

#### ツール

1. `get_symbols_overview` でファイル概要把握
2. `find_symbol` で特定シンボル検索
3. `find_referencing_symbols` で参照関係調査
4. `search_for_pattern` でパターン検索

#### 注意

- ファイル全体を読む前にシンボルレベルの調査を優先し、必要最小限のコードのみ読み込む

### Playwright MCP: Web 動作確認/UI テスト

#### 用途

- UI 表示、動作確認
- ユーザフロー検証

#### ツール

1. `browser_navigate` でページ遷移
2. `browser_snapshot` で状態取得
3. `browser_click`, `browser_type` 等で操作
4. `browser_take_screenshot` でスクリーンショット取得

## 代替手段

- 指定の MCP サーバが使用できない場合は、標準ツールで代用
- 指定のツールが使用できない場合は、`tools/list` で最適ツールを選択
