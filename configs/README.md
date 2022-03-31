# chezmoi

chezmoi はファイルの内容と権限を管理する。  
システムの制御や until / retries 等の高度な操作は Ansible に任せる。

[.chezmoi.toml.tmpl](./.chezmoi.toml.tmpl) は chezmoi 自身の config で、`chezmoi init` が `~/.config/chezmoi/chezmoi.toml` へ展開する。ソースステートの読み込み前に評価されるため配置対象にはならず、`init` のたびに再生成される（端末側での手編集は失われる）。`sourceDir` をこのファイル自身が宣言するため、[import.sh](../import.sh) が `--source` を渡す必要があるのは初回だけ。

[.chezmoiexternal.toml](./.chezmoiexternal.toml) は `chezmoi apply` 時にリポジトリ外から取ってくるものを宣言しており、実体を git に取り込まずに宛先への配置を可能にする。取得済みのリソースは `refreshPeriod` が経過するまで再取得されず、未指定（既定値 `0`）の場合は初回取得のみで二度と更新されない（`file` はダウンロードキャッシュの mtime、`git-repo` は最後に clone / pull した時刻を chezmoi が保持して判定する）。その場で強制更新するには `chezmoi apply -R always` を使う。

`chezmoi re-add` は既に管理下にあるファイルのみを対象とするため、新規ファイルは `chezmoi add` を一度実行する必要がある。管理対象の一覧は `chezmoi managed` で確認できる。

ファイル名の接頭辞が、配置先のパーミッションを決める（umask 022 の場合）。

| 接頭辞              | ファイル | ディレクトリ | 用途                       |
| ------------------- | -------- | ------------ | -------------------------- |
| （なし）            | 644      | 755          | 既定                       |
| `executable_`       | 755      | -            | 実行権限が必要なスクリプト |
| `private_`          | 600      | 700          | 他ユーザに見せない設定     |
| `readonly_`         | 444      | 555          | 書き換えを防ぐ設定         |
| `private_readonly_` | 400      | 500          | 上記の組み合わせ           |

`dot_` は先頭ドットへの変換（`dot_zshrc` → `~/.zshrc`）、`exact_` は「chezmoi 管理外のファイルを配置先から削除する」を意味し、いずれもパーミッションには影響しない。

パーミッションは接頭辞のみで決まり、リポジトリ側のファイルの実際のモードは参照されない。既存の権限を変えたくない場合は `chezmoi apply --dry-run -v` で確認すること（`~/Library` は macOS 既定が 700 のため `private_` が必要）。

`symlink_` は配置先にシンボリックリンクを作る接頭辞で、そのファイルの中身がリンク先パスとして解釈される（ファイル本体を置くことはできない）。リンク先の実体はドット始まりのため chezmoi の管理対象から外れる（同じ配置先を二重に定義しないための措置）。配置先への変更がリポジトリの実体へ直結するため、端末側で試行錯誤する設定には向かない。

実体を [.chezmoiroot](../.chezmoiroot) の外に置いたまま配布したい場合は `.tmpl` の `include` を使う（[dot_config/mise/config.toml.tmpl](./dot_config/mise/config.toml.tmpl) → [packages/mise.toml](../packages/mise.toml)）。相対パスは chezmoi のソースディレクトリ起点で解決される。配置先には実体ファイルが作られるため、端末側の変更はリポジトリに波及せず `chezmoi diff` に差分として現れる。ただし `chezmoi re-add` はテンプレートを書き換えないため、退避経路は別途用意すること（mise の場合は [export.sh](../export.sh) が担当）。

管理下のファイルを端末側で変更した後に `chezmoi apply` すると、上書き可否を問うプロンプトが出る（`--force` で抑止可能）。

`run_after_` は `chezmoi apply` 後にキックされるスクリプト。ファイル名の順に実行される。`run_onchange_after_` は内容が変わった時のみ実行されるため、リポジトリ側ファイルのハッシュをコメントに埋めれば「その定義が変わった時だけ走る」処理を書ける（[run_onchange_after_mise-install.sh.tmpl](./run_onchange_after_mise-install.sh.tmpl) は [packages/mise.toml](../packages/mise.toml) をキーにしている）。

`run_onchange_` が非ゼロ終了した場合、chezmoi は実行済みと記録せず次回 apply で再試行する。

実行時のカレントディレクトリは配置先（`$HOME`）のため、リポジトリ内のファイルを参照するには `.tmpl` にして `{{ .chezmoi.workingTree }}` を使う。
