# Claude Code

[private_settings.json](./private_settings.json) の `permissions` を書く前提として、Claude Code 本体のバイナリを解析して判明した挙動を記録する（2.1.295 で調査、2.1.287 も対象コマンドと許可フラグは同一）。

## 既定の read-only コマンド

[公式ドキュメント](https://code.claude.com/docs/en/permissions#read-only-commands) には代表例と "read-only forms of git" とあるのみで全量の一覧は無い。以下に該当する Bash コマンドは全モードでプロンプト無しに実行される（ask / deny ルールが優先）。設定では変更できない。

### 共通の除外条件

次のいずれかに当たると、コマンド自体が下記に該当しても対象外になる。パイプや `&&` で繋いだ複合コマンドは、全ての部分が read-only の場合のみ対象。

- 出力リダイレクト（`/dev/null` と `2>&1` 等の fd 複製を除く）
- クォート外の変数展開、コマンド置換、サブシェル、`&` によるバックグラウンド実行
- 安全リスト外の環境変数の前置代入、`~user` 形式のパス、10,000 文字超
- 未クォートの glob（許されるのは `ls` `cat` `head` `tail` `wc` `stat` `grep` `egrep` `fgrep` `diff` `du` `df` `echo` `strings` `hexdump` `od` `nl` `cut` `column` `tr` `tac` `rev` `cmp` `basename` `dirname` `realpath` `readlink` `sha256sum` `sha1sum` `md5sum` `cd` のみ）

### 引数を問わないもの

`ls` `echo` `cat` `head` `tail` `wc` `stat` `strings` `hexdump` `od` `nl` `cut` `paste` `tr` `column` `tac` `rev` `fold` `expand` `unexpand` `fmt` `comm` `cmp` `diff` `numfmt` `basename` `dirname` `realpath` `readlink` `which` `type` `expr` `seq` `tsort` `pr` `true` `false` `sleep` `id` `uname` `free` `df` `du` `locale` `groups` `nproc` `cal` `uptime`

`docker ps` / `docker images` も含む（別デーモンを指す `-H` `--context` 等は不可）。

### 形が限定されるもの

| コマンド                                                                                                | 条件                                                                                                                            |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `pwd` `whoami` `alias`                                                                                  | 引数なしのみ                                                                                                                    |
| `cd`                                                                                                    | 引数 1 個まで。移動先は作業ディレクトリ内                                                                                       |
| `find`                                                                                                  | `-exec` `-execdir` `-ok` `-okdir` `-delete` `-fprint` `-fprint0` `-fprintf` `-fls` `-files0-from` を含まない                    |
| `printf`                                                                                                | オプション不可。書式に `$` や `\u` を含まず、`%d` 等の数値変換を使う場合は引数が数値リテラルのみ                                |
| `[[ ... ]]`                                                                                             | 算術比較（`-eq` 等）の被演算子は数値リテラルのみ                                                                                |
| `history`                                                                                               | 引数なしか数値 1 個                                                                                                             |
| `arch`                                                                                                  | 引数なしか `-h` / `--help`                                                                                                      |
| `ifconfig`                                                                                              | 引数なしかインターフェース名 1 個                                                                                               |
| `jq`                                                                                                    | `-f` `-L` `--from-file` `--rawfile` `--slurpfile` `--run-tests` `--library-path` と、`env` `$ENV` `include` `import` を含まない |
| `uniq`                                                                                                  | フラグのみ（ファイル引数不可、パイプ入力専用）                                                                                  |
| `ip addr` `node -v` `node --version` `python --version` `python3 --version` `claude -h` `claude --help` | 完全一致のみ                                                                                                                    |

### 許可フラグ表で判定するもの

表に無いフラグを 1 つでも含むと対象外になる。位置引数（ファイル・パス等）は自由だが、`{a,b}` / `{1..3}` 形式を含むと対象外。

| コマンド                                                              | 条件・主な除外                                                                                                                             |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `grep` `egrep` `fgrep`                                                | 一般的な検索フラグはほぼ全て可                                                                                                             |
| `rg`                                                                  | `--pre` `--hostname-bin` `-z` / `--search-zip` 等は不可                                                                                    |
| `fd` `fdfind`                                                         | `-x` / `--exec`、`-X` / `--exec-batch`、`-l` / `--list-details` は不可                                                                     |
| `tree`                                                                | `-o`（ファイル出力）は不可                                                                                                                 |
| `sort`                                                                | `-o` / `--output`、`-T`、`--compress-program` は不可                                                                                       |
| `sed`                                                                 | `-n` と行表示（`p` / `5p` / `1,10p`）の組み合わせか、ファイル指定なし（パイプ入力）での単一の置換 `s/a/b/g` のみ。`-i` や `w` / `e` は不可 |
| `file`                                                                | `-m` / `--magic-file`、`-f` / `--files-from` は不可                                                                                        |
| `ps`                                                                  | 環境変数を表示する `e` オプションは不可                                                                                                    |
| `date`                                                                | 位置引数は `+書式` のみ（時刻の設定は不可）                                                                                                |
| `hostname`                                                            | フラグのみ（ホスト名の変更は不可）                                                                                                         |
| `tput`                                                                | `init` `reset` `clear` 等の端末制御と `-S` は不可                                                                                          |
| `man` `help`                                                          | パスを含む引数は不可                                                                                                                       |
| `xargs`                                                               | 実行対象が `echo` `printf` `wc` `grep` `egrep` `fgrep` `head` `tail` の場合のみ                                                            |
| `test`                                                                | 算術比較の被演算子は数値リテラルのみ。`-a` `-o` `-v` `-R` は不可                                                                           |
| `docker logs` `docker inspect`                                        | 別デーモンの指定は不可                                                                                                                     |
| `base64` `sha256sum` `sha1sum` `md5sum` `lsof` `pgrep` `netstat` `ss` | 表示・検証系フラグのみ                                                                                                                     |
| `git`                                                                 | 次節                                                                                                                                       |

### git

サブコマンドごとに許可フラグ表を持つ。表に無いサブコマンドは対象外。

| サブコマンド                                  | 条件・主な許可フラグ                                                                                                    |
| --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `git diff`                                    | `--stat` `--name-only` `--cached` `--word-diff` 等。`--output` `--ext-diff` `--textconv` は不可                         |
| `git log` / `git show`                        | `--oneline` `-n` `-20` `--graph` `-p` `--stat` `--grep` `--follow` 等。`--format` は署名系（`%G` 等）と未知の別名が不可 |
| `git status`                                  | `--short` `--branch` `--porcelain` 等。`--porcelain=v2` や `-uno` は不可                                                |
| `git branch` / `git tag`                      | 一覧系のみ（`--show-current` `--list` `-a` `-vv` `--merged` 等）。名前を渡す作成・削除は不可                            |
| `git blame`                                   | `-L` `--porcelain` `-w` `-M` `-C` 等                                                                                    |
| `git rev-parse`                               | `--show-toplevel` `--abbrev-ref` `--verify` `--short` 等                                                                |
| `git describe` / `git merge-base`             | 主要フラグはほぼ全て                                                                                                    |
| `git remote`                                  | `-v` のみ。`git remote show -n <name>` も可                                                                             |
| `git ls-remote`                               | フラグのみ（URL・リモート名の引数は不可）                                                                               |
| `shortlog` `reflog` `rev-list` `for-each-ref` | ログ系と同様の表示フラグ。`reflog` は `show` / `list` のみ                                                              |
| `ls-files` `grep` `cat-file` `config --get`   | 読み取りフラグのみ（`cat-file` は `-t` `-s` `-p` `-e` `--batch-check`）                                                 |
| `stash list` `stash show` `worktree list`     | 表示フラグのみ                                                                                                          |

表に該当しても次の場合は対象外になる。

- `git` 直後にグローバルオプションがある（`git --no-pager log` / `git -C dir log` / `git -c k=v ...`）
- `cd` との複合コマンド、カレントに bare repo の兆候がある、sandbox 有効時に cwd が起動ディレクトリと異なる

gh にも read-only 表（`gh pr view` 等）が存在するが、外部向けビルドでは参照されておらず無効。gh の allow ルールは既定と重複しない。

## allow ルールの方針

- 既定の read-only で足りるコマンドは allow に書かない。`Bash(git diff *)` 等は既定より広く、既定が除外する `--output`（ファイル書き込み）、`--ext-diff` / `--textconv`（設定された外部プログラムの実行）、`--show-signature` / `--format=%G?`（gpg の実行）まで許可してしまう。`Bash(tree *)` の `-o`、`Bash(jq *)` の `env` / `--rawfile` も同様
- `rg` の `--pre` / `--hostname-bin` は既定でも除外されるが、deny にも残している
- `git restore` は allow、ブランチ切り替え（`git checkout` / `git switch`）は ask。作業の大半を Claude が行うため、未コミット変更の破棄（`git restore .` 等、復元不可）のリスクを受容している。allow は classifier より先に判定されるため、auto モードで classifier が既定でブロックする `git restore .` も確認無しで通る。同じ復元でも `git checkout -- <path>` の形は ask に掛かる
- auto モードでは allow ルール一致と read-only 判定のどちらも classifier を経由せず承認されるため、重複ルールに得は無い
- `git --no-pager diff/log` は既定の対象外のため allow に残す。Bash ツールの stdout は TTY ではなく pager は起動しないため `--no-pager` 自体は不要だが、Claude が付けがちなため。許可範囲は既定より広く、`--output` は [validate.sh](./executable_validate.sh) で遮断している

## ネットワーク許可

[公式ドキュメント](https://code.claude.com/docs/en/sandboxing#network-isolation) の記載と 2.1.287 のバイナリで確認した挙動。

| 設定                                  | WebFetch ツール              | sandbox 内の Bash（curl / git / npm 等） |
| ------------------------------------- | ---------------------------- | ---------------------------------------- |
| `WebFetch(domain:X)` の allow         | 確認無しで取得               | X に接続可                               |
| `sandbox.network.allowedDomains` の X | 効果無し（通常の承認フロー） | X に接続可                               |
| `WebFetch(domain:X)` の deny          | 遮断                         | X への接続を遮断                         |
| `sandbox.network.deniedDomains` の X  | 効果無し                     | X への接続を遮断                         |

- `WebFetch(domain:...)` の allow / deny ルールは sandbox の許可 / 拒否リストに合流する。逆方向は無く、WebFetch だけ許可して Bash からの接続を許可しない設定はできない
- 合流するのは `domain:` 付きの形のみで、`WebFetch` 単体のルールは sandbox に効かない。WebFetch・sandbox のどちらでも deny が allow に優先する
- sandbox に効くワイルドカードは先頭の `*.` と単独の `*` のみ。`*.example.com` はサブドメインにのみ一致し、`example.com` 自体には一致しない（WebFetch も同じ）
- sandbox のネットワーク承認で「今後確認しない」を選ぶと、`.claude/settings.local.json` に `WebFetch(domain:...)` として保存される
- 接続先が許可済みでも、`Bash(curl *)` 等の ask ルールに一致するコマンドは auto モードでも確認が出る

### 書き分けの方針

- WebFetch で読む意味のあるホスト（ドキュメント、認証不要の API 等）は `WebFetch(domain:...)` に書く。Bash からの接続許可も兼ねる
- WebFetch で読む意味の無いホスト（認証必須の API、CLI 専用の CDN やテレメトリ、localhost / IP / ポート指定）は `allowedDomains` に書く
- `WebFetch(domain:...)` に追加したホストは Bash の接続先にもなる
- 遮断は、Bash からの接続を塞げば足りるホスト（アップロード先等。WebFetch は取得のみで送信できない）を `deniedDomains` に、WebFetch でも読ませたくないホストを deny の `WebFetch(domain:...)` に書く

## 起動時の permission mode

`env` の `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` が有効だと、ターミナルで起動したセッションの permission mode は `default`（Manual）に固定される。公式ドキュメントには記載が無く、2.1.287 のバイナリで確認した。

- 起動モードの判定はこの変数を最初に見るため、`permissions.defaultMode` も `--permission-mode` も効かない
- 警告（`Permission mode forced to default — ...`）は `--permission-mode` 等でモードを明示した場合のみ表示される。`claude` だけで起動すると何も表示されずに Manual で始まる
- 警告中の "Declare allowedTools explicitly" は、Manual 固定下で `--allowedTools` により許可を渡す案内で、auto には戻らない
- 本来は `claude-code-action` が `allowed_non_write_users` 設定時に自動で有効にする変数で、その hardening が個人環境にも適用されている
- 起動後に `Shift+Tab` で auto へ切り替えることはできる。スクラブの有効・無効は起動時の環境変数で一度だけ決まり permission mode を参照しないため、切り替え後もスクラブは効いたまま

サブプロセス（Bash・フック・stdio の MCP サーバー）の環境変数から資格情報を除く効果を優先して有効のままにし、起動後に手動で auto へ切り替える。スクラブの対象は環境変数のみで、ファイル上の資格情報は sandbox の読み取り拒否と `Read(...)` の deny で守る。`GH_TOKEN` / `GITHUB_TOKEN`・プロキシ設定・`GIT_CONFIG_*` は仕様で残り、名前・値とも資格情報に見えない秘密も残る。

## Remote Control と feature flag

`remoteControlAtStartup: true` でも、`env` の設定次第で Remote Control に接続されない。[公式ドキュメント](https://code.claude.com/docs/en/remote-control#requirements) の記載。

Remote Control は Anthropic から取得する feature flag で有効化される。次の変数はいずれも flag の取得を止めるが、Remote Control への影響は異なる。

| 変数                                                              | Remote Control                                                          |
| ----------------------------------------------------------------- | ----------------------------------------------------------------------- |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` / `DISABLE_GROWTHBOOK` | 使用不可                                                                |
| `DISABLE_TELEMETRY` / `DO_NOT_TRACK`                              | 2.1.283 以降は使用可。組織が Trusted Devices を必須にしている場合は不可 |

- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` は `0` / `false` でも有効扱いになるため、キーごと削除する
- 接続できない場合のメッセージ `Remote Control requires feature-flag evaluation` に原因の変数名が含まれる
- [.zprofile](../dot_zprofile) の `DO_NOT_TRACK` も上表の対象
- flag の取得停止で使えなくなる機能は Remote Control 以外にもあり（[一覧](https://code.claude.com/docs/en/env-vars#features-that-need-feature-flag-fetching)）、`DISABLE_TELEMETRY` / `DO_NOT_TRACK` を設定している限り使えない

Remote Control を使うため `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` は設定せず、同変数が止めていたもののうち必要なものを個別の変数で止める。

| 同変数が止めていたもの                                                                              | 対応                                         |
| --------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| テレメトリ                                                                                          | `DISABLE_TELEMETRY`                          |
| エラーレポート                                                                                      | `DISABLE_ERROR_REPORTING`                    |
| `/feedback`（`/bug` `/share` を含む）、Claude-drafted feedback                                      | `DISABLE_FEEDBACK_COMMAND`                   |
| 自動更新                                                                                            | 不要（Homebrew cask は既定で自動更新しない） |
| リリースノート、PR ステータスバッジ、fast mode の可用性チェック、plugin の `command` ソースの再実行 | 止めない                                     |

## 再調査

一覧はバージョンアップで変わりうる。現行バイナリでは次で確認できる（`...Xx` は共通フラグ群の展開で、中身は同じバイナリ内の定義を参照）。その他の許可フラグ表は `{xargs:{safeFlags:` から始まるオブジェクトにまとまっている。

```sh
B="$(readlink -f "$(command -v claude)")"
# 引数を問わないコマンド
strings -n 6 "$B" | grep -o '"cal","uptime"[^]]*'
# git の許可フラグ表
strings -n 6 "$B" | grep -o '"git [a-z -]*":{safeFlags:{[^}]*}'
# SUBPROCESS_ENV_SCRUB による起動モードの固定（ヒットすれば存続）
strings -n 6 "$B" | grep -o 'Permission mode forced to default[^"]*'
```
