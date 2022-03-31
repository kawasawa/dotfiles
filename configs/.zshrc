# ******************************************************************************
# zsh 設定ファイル
# ------------------------------------------------------------------------------
# 依存関係
#   - Homebrew: パッケージ管理ツール
#   - mise: ランタイム管理ツール
#   - zplug: Zsh プラグイン管理ツール
# ******************************************************************************

# ------------------------------------------------------------------------------
# 環境変数
# ------------------------------------------------------------------------------

# ロケール
export LANG=ja_JP.utf-8
export LESSCHARSET=utf-8

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
_BREW_PREFIX="$(brew --prefix)"
export HOMEBREW_FORBIDDEN_FORMULAE="python python3 pip node npm pnpm yarn"

# mise
eval "$(mise activate zsh)"
eval "$(mise activate --shims)"
export MISE_LEGACY_VERSION_FILE=1

# JetBrains Toolbox
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools


# ------------------------------------------------------------------------------
# プラグイン
# ------------------------------------------------------------------------------

if [ -f ~/.zplug/init.zsh ]; then
  source ~/.zplug/init.zsh
  zplug 'zplug/zplug', hook-build:'zplug --self-manage'

  zplug 'mafredri/zsh-async'                          # Zsh 内での非同期処理を実現 ('sindresorhus/pure' が依存する)
  zplug 'sindresorhus/pure'                           # pure テーマを適用
  zplug 'zsh-users/zsh-completions'                   # Tab キー押下でコマンドのオプションを一覧表示
  zplug 'zsh-users/zsh-autosuggestions', defer:2      # [compinit 実行後] 合致する入力履歴をサジェスト表示
  zplug 'zsh-users/zsh-syntax-highlighting', defer:2  # [compinit 実行後] コマンドにシンタックスハイライトを適用

  # fzf: インクリメンタルサーチツール
  # Homebrew でも導入可能だがほぼシェル専用のツールのためプラグインとして管理したい
  #   see: https://github.com/zplug/zplug/issues/582#issuecomment-1328361274
  #     (以下全て推測、正直よく分からない)
  #     通常は as:command, use, rename-to で実行ファイルの特定及びシンボリックリンクの命名と生成を行う
  #     が、肝心の実行ファイル bin/fzf は install スクリプトの実行後に生成される
  #     そのためプラグインの読み込み時にシンボリックリンクを手動で作成する
  zplug 'junegunn/fzf', \
    from:github, \
    as:command, \
    use:bin/fzf, \
    rename-to:fzf, \
    hook-build:". $ZPLUG_HOME/repos/junegunn/fzf/install --bin", \
    hook-load:"command -v fzf >/dev/null 2>&1 || ln -sf $ZPLUG_HOME/repos/junegunn/fzf/bin/fzf $ZPLUG_HOME/bin/fzf"

  # enhancd: ディレクトリ移動強化
  zplug 'b4b4r07/enhancd', use:init.sh

  if ! zplug check --verbose; then
    printf 'install plugins? (y/n [n]): '
    if read -q; then
      echo; zplug install
    fi
  fi
  # zplug load --verbose
  zplug load
fi

# fzf
# source ~/.fzf.zsh
source <(fzf --zsh)
export FZF_DEFAULT_OPTS='--reverse --inline-info --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# enhancd
export ENHANCD_FILTER='fzf --height 25%'  # インクリメンタルサーチに fzf を使用
export ENHANCD_DISABLE_DOT=1              # `cd .` は Zsh 標準の動作を使う
export ENHANCD_DISABLE_HOME=1             # `cd ~` は Zsh 標準の動作を使う


# ------------------------------------------------------------------------------
# 基本動作
# ------------------------------------------------------------------------------

export EDITOR='vim'          # 編集用のエディタ
export VISUAL="$EDITOR"      # 表示用のエディタ
setopt prompt_subst          # プロンプト内の変数を展開
setopt interactive_comments  # コメント識別を有効化
setopt numeric_glob_sort     # 自然順ソートを有効化
setopt no_beep               # ビープ音を無効化
setopt nolistbeep            # 補完候補表示時のビープ音を無効化


# ------------------------------------------------------------------------------
# 履歴管理
# ------------------------------------------------------------------------------

export HISTFILE=~/.zsh_history           # 履歴を保存するファイル
export HISTSIZE=10000                    # メモリに展開される履歴数
export SAVEHIST=10000                    # 履歴ファイルに保存される履歴数
export HISTORY_IGNORE='(cd|pwd|l[sal])'  # 履歴ファイルに保存しないコマンド
setopt share_history                     # プロセス間で履歴を常時共有 (複数のシェルで同じ履歴を常時参照可能になる)
setopt inc_append_history                # 履歴ファイルに即時追記 (Zsh 内で手動で .zsh_history を更新しても競合が起こらなくなる)
setopt hist_expire_dups_first            # 履歴の上限に達した場合、重複する履歴を優先的に削除
setopt hist_ignore_all_dups              # 重複する履歴が存在する場合は新しいもののみを保持
setopt hist_ignore_dups                  # 直前と同一コマンドは無視
setopt hist_no_store                     # history コマンドは無視
setopt hist_ignore_space                 # 空白で始まるコマンドは無視
setopt hist_reduce_blanks                # コマンド内の余計な空白を除去


# ------------------------------------------------------------------------------
# 入力補完
# ------------------------------------------------------------------------------

# compinit は Zsh の補完システムの初期化 (.zcompdump を生成する) 処理である
# 補完系の外部プラグインの多くがこれに依存するため、それらよりも先に実行しておく必要がある
# bashcompinit は上記の Bash 用バージョンだが AWS 等の CLI が提供する補完スクリプトは Bash 形式が多い
autoload -Uz compinit && compinit
autoload -U bashcompinit && bashcompinit

setopt correct                                       # スペル訂正を有効化
setopt complete_in_word                              # 入力途中でも補完候補を表示
setopt list_packed                                   # 補完候補の余白を縮小
setopt magic_equal_subst                             # 引数 ("=" 以降の部分など) の補完を有効化
zstyle ':completion:*:default' menu select=1         # 補完候補のカーソル選択
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # 補完候補に大文字の要素を追加
zstyle ':completion:*' list-colors $LS_COLORS        # ファイル候補のカラー表示

# AWS CLI
export PATH="$PATH:$_BREW_PREFIX/bin/aws_completer"
complete -C "$_BREW_PREFIX/bin/aws_completer" aws
#
# # Azure CLI
# source "$_BREW_PREFIX/etc/bash_completion.d/az"
#
# # gcloud CLI
# source "$_BREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
# source "$_BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"


# ------------------------------------------------------------------------------
# キーバインド
# ------------------------------------------------------------------------------

# カーソル移動
bindkey '[C' forward-word         # option+Left:  単語左端へ移動
bindkey '[D' backward-word        # option+Right: 単語右端へ移動
# (初期状態で ⌘ ←, ⌘ → で動作するが Ghostty + MSEdit のカスタム環境で競合するため)
bindkey '\e[H' beginning-of-line  # fn+Left: 行頭へ移動
bindkey '\e[F' end-of-line        # fn+Right: 行末へ移動

# 入力中のテキストでコマンド履歴を検索
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search    # up:   入力内容と先頭一致する一つ前のコマンド履歴
bindkey '^[[B' down-line-or-beginning-search  # down: 入力内容と先頭一致する一つ次のコマンド履歴

# history にインクリメンタルサーチを適用
function select-history() {
  BUFFER=$(\history -n -r 1 | fzf --query "$LBUFFER")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^R' select-history  # ctrl+R: コマンド履歴検索


# ------------------------------------------------------------------------------
# エイリアス
# ------------------------------------------------------------------------------

# エイリアス一覧表示
function alias() {
  # 引数がある場合は Zsh 標準の alias コマンドを実行
  if [[ $# -gt 0 ]]; then
    builtin alias "$@"
    return
  fi

  # 引数が無い場合は Zsh のエイリアスに加え他のツールで定義されたエイリアスを結合して一覧表示
  local alias_output=""
  # Zsh のエイリアス
  alias_output=$(builtin alias)
  # Git のエイリアス (.gitconfig に定義された alias コマンド)
  if git config --get alias.alias >/dev/null 2>&1; then
    alias_output="$alias_output\n$(git alias | sed 's/^/git /')"
  fi
  # 結果をインクリメンタルサーチ
  local fzf_selected=$(echo "$alias_output" | sed "s/=/ => /" | fzf)
  if [[ -n "$fzf_selected" ]]; then
    echo "$fzf_selected" | sed "s/ => /\n  => /"
  fi
}

# Obsidianに追記
function td() {
  if [ -z "$1" ]; then
    echo "[ERROR] content is required." >&2
    return 1
  fi

  VAULT_NAME="second-brain"
  DIR_NAME="TODO"
  NOTE_NAME="$(date +'%Y-%m-%d').md"

  OBSIDIAN_PATH="${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents"
  NOTE_PATH="${OBSIDIAN_PATH}/${VAULT_NAME}/${DIR_NAME}/${NOTE_NAME}"
  if [ ! -f "$NOTE_PATH" ]; then
    echo "creating a new note..."
    mkdir -p "$(dirname "$NOTE_PATH")" && touch "$NOTE_PATH"
  fi

  CONTENT=$'\n- '`date +'%H:%M'`' '"$1"
  echo -n $CONTENT >> "$NOTE_PATH"
  echo "appended to ${NOTE_NAME}"
}

# 基本操作
alias ..='cd ..'    # 親階層の一覧から選択して移動
alias cp='cp -i'    # 上書前に確認実施
alias mv='mv -i'    # 上書前に確認実施
alias rm='rm -i'    # 削除前に確認実施
alias la='ls -a'    # a: 隠しファイルを表示
alias ll='ls -l'    # l: ファイルの詳細情報を表示
alias lla='ls -la'  # 全ファイルの詳細情報を表示

# シェル操作
alias reload='exec $SHELL -l'                # シェルを再起動
alias bench='repeat 10 time zsh -i -c exit'  # シェルの起動時間を計測

# 互換コマンド
if command -v eza > /dev/null 2>&1; then
  alias ls='eza --git --time-style="+%Y-%m-%d %H:%M:%S"'
fi
if command -v bat > /dev/null 2>&1; then
  alias cat='bat --theme=Dracula --style=plain'
fi
if command -v rg > /dev/null 2>&1; then
  # --line-number: 行番号を表示
  # --no-heading: ファイル名とマッチ行を併記
  # --hidden: 隠しファイルを含める
  # --binary: バイナリファイルを含める
  alias grep='rg --line-number --no-heading --hidden --binary'
fi
if command -v fd > /dev/null 2>&1; then
  # --hidden: 隠しファイルを含める
  # --no-ignore: .gitignore 等の設定を無視
  alias find='fd --hidden --no-ignore'
fi

# ツール起動
alias c='copilot'  # GitHub Copilot CLI
alias e='edit'     # Microsoft Edit
alias f='yazi'     # CLI Filer
alias g='gitui'    # Git TUI
