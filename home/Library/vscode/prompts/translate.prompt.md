---
name: translate
description: 文章ファイルに翻訳を併記する。
disable-model-invocation: true
---

# 翻訳併記

- 文章ファイル ($ARGUMENTS) に翻訳併記
- 翻訳併記以外の作業は一切不要

## 要件

- 翻訳は文章ファイル ($ARGUMENTS) に直接追記
- 原文が日本語であれば英訳を、日本語以外であれば日本語訳を併記
- フォーマル寄りの自然な表現で翻訳 (原文のニュアンスやトーンを極力保持)
- 原文と翻訳の対応を明確化するため段落ごとに翻訳併記
- 既に翻訳併記済みの場合、原文と翻訳の間に乖離があれば翻訳を更新

## 注意事項

- 原文は変更禁止
- URLは翻訳不要
- コードブロックは翻訳不要

## 考慮事項

- 原文は誤字脱字や文法不備が混在する
  - 人間が書いているため
- 原文は不規則な文字コードや改行が混在する
  - メッセージツールやドキュメントツールからコピーされるため

## 動作例

- 原文

---
　日本語の段落1
日本語の文章1-1
日本語の文章1-2
　日本語の段落2
日本語の文書2-1

[ソースコード](https://example.com)

`console.log("こんにちは、世界")`

```ts
  const message = "こんにちは、世界";
```

　日本語の段落3
日本語の文書3-1
---

- 翻訳併記後

---
　日本語の段落1
日本語の文章1-1
日本語の文章1-2
  English translation of paragraph 1
English translation of sentence 1-1
English translation of sentence 1-2

　日本語の段落2
日本語の文書2-1
  English translation of paragraph 2
English translation of sentence 2-1

[Source code](https://example.com)

`console.log("こんにちは、世界")`

```ts
  const message = "こんにちは、世界";
```

　日本語の段落3
日本語の文書3-1
  English translation of paragraph 3
English translation of sentence 3-1
---