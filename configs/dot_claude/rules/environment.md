---
description: 環境に依存した固有のルール
applyTo: "**"
---

# 環境固有ルール

- 破壊を伴う検証は `$TMPDIR` のコピーで実施
- ファイルの復元/ステージ解除には `git restore` を使用(`checkout`/`reset` は承認が必要)
- `git push -u` は `|/&&/;/cd/git -C` と組み合わせるとサンドボックス制限により `.git/config` への upstream 書き込みに失敗する(push 自体は成功している)
