---
applyTo: "**"
description: "タスクに応じた最適なMCPサーバの使用規約"
---

# MCP サーバ使用規約

## 推奨

### Context7 MCP: ドキュメント/パッケージ調査

#### 用途

- 未知のパッケージの理解
- 最新ベストプラクティス、機能、使用方法の調査

#### ツール

1. `resolve-library-id` で ID 取得
2. `get-library-docs` でドキュメント取得

### Serena MCP: コード解析/構造理解

#### 用途

- コードの構造理解
- シンボル検索 (クラス、関数等)
- 参照関係調査
- 変更範囲特定

#### ツール

1. `get_symbols_overview` でファイル構造把握
2. `find_symbol` でシンボル検索
3. `find_referencing_symbols` で参照関係調査
4. `search_for_pattern` でパターン検索

#### 重要

- ファイル全体を読む前に必ずシンボルで検索し、最小限のコードのみ読み込む

## 例外

- 指定の MCP サーバが使用できない場合は、標準ツールで代用
- 指定のツールが使用できない場合は、`tools/list` で最適ツールを選択

### Obsidian MCP: ナレッジ検索/取得

#### 用途

- 過去のナレッジを確認
- 過去のドキュメントやレビューの雛形を確認

#### ツール

1. `mcp_obsidian_search_notes` でノートを検索
2. `mcp_obsidian_read_notes` でノートの内容を参照

#### 重要

- 「Obsidian を確認して」等明示的に `Obsidian` 内の資料を探索するよう指示がある場合に使用
