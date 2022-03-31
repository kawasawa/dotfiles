# ******************************************************************************
# zsh 設定ファイル
# ******************************************************************************

export PATH=$HOME:$PATH
export LANG=ja_JP.utf-8
export LESSCHARSET=utf-8

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
_BREW_PREFIX="$(brew --prefix)"

# mise
if type mise > /dev/null 2>&1; then eval "$(mise activate zsh)"; fi
export MISE_LEGACY_VERSION_FILE=1

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
export FZF_DEFAULT_OPTS='--reverse --inline-info --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'


# ------------------------------------------------------------------------------
# プラグインの管理
# ------------------------------------------------------------------------------

if [ -f ~/.zplug/init.zsh ]; then
  source ~/.zplug/init.zsh
  zplug 'zplug/zplug', hook-build:'zplug --self-manage'

  zplug 'dracula/zsh', as:theme
  zplug 'chrissicool/zsh-256color'
  zplug "b4b4r07/enhancd", use:init.sh

  zplug 'zsh-users/zsh-history-substring-search'           # 入力中のコマンドで履歴検索
  zplug 'zsh-users/zsh-completions', defer:1               # コマンドの入力補完
  zplug 'zsh-users/zsh-autosuggestions', defer:2           # コマンドのサジェスト表示
  zplug 'zsh-users/zsh-syntax-highlighting', defer:3       # コマンドのシンタックスハイライト

  # zplug 'superbrothers/zsh-kubectl-prompt'

  # プラグインのインストール
  if ! zplug check --verbose; then
    printf 'install plugins? (y/n [n]): '
    if read -q; then
      echo;
      zplug install
    fi
  fi
  zplug load
fi

# dracula
export ZSH_THEME='dracula'

# enhancd
export ENHANCD_FILTER='fzf --height 25%'
export ENHANCD_DISABLE_DOT=1
export ENHANCD_DISABLE_HOME=1


# ------------------------------------------------------------------------------
# プロンプトの動作
# ------------------------------------------------------------------------------

setopt prompt_subst          # プロンプト内の変数を展開
setopt no_beep               # ビープ音を無効化
setopt numeric_glob_sort     # 自然順ソートを有効化
setopt interactive_comments  # コメント識別を有効化

# 空行の自動追加
function add-newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}
_PROMPT_COMMAND="add-newline; $_PROMPT_COMMAND"


# ------------------------------------------------------------------------------
# 履歴管理
# ------------------------------------------------------------------------------

export HISTFILE=~/.zsh_history  # 履歴を保存するファイル
export HISTSIZE=1000            # メモリに保存される履歴数
export SAVEHIST=100000          # ファイルに保存される履歴数
setopt inc_append_history       # プロセスを横断して履歴を追記
setopt share_history            # プロセス間で履歴を常時共有
setopt hist_ignore_all_dups     # 最新以外の重複した履歴を除去
setopt hist_ignore_dups         # 直前と同一のコマンドは除外
setopt hist_reduce_blanks       # 空コマンドは除外


# ------------------------------------------------------------------------------
# 入力補完
# ------------------------------------------------------------------------------

# .zcompdump が直近で更新されていない場合はキャッシュを使用する
autoload -Uz compinit
[[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]] && compinit || compinit -C

autoload -Uz bashcompinit && bashcompinit

setopt correct                                       # スペル訂正を有効化
setopt complete_in_word                              # 入力途中でも補完候補を表示
setopt list_packed                                   # 補完候補の余白を縮小
setopt magic_equal_subst                             # 引数での補完を有効化
zstyle ':completion:*:default' menu select=1         # 補完候補のカーソル選択
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # 補完候補に大文字の要素を追加
zstyle ':completion:*' list-colors $LS_COLORS        # ファイル候補のカラー表示


# ------------------------------------------------------------------------------
# エイリアス
# ------------------------------------------------------------------------------

# ディレクトリ移動
alias ..='cd ..'

# ファイル操作
alias cp='cp -i'  # 上書前に確認実施
alias mv='mv -i'  # 上書前に確認実施
alias rm='rm -i'  # 削除前に確認実施

# 互換コマンド
alias ls='eza --git --time-style="+%Y-%m-%d %H:%M:%S"'  # ファイル一覧表示
alias la='ls -a'                                        # 全ファイルを表示
alias ll='ls -l'                                        # 詳細情報を表示
alias lla='ls -la'                                      # 全ファイルの詳細情報を表示
alias cat='bat --style=plain'                           # 標準出力
alias diff='delta --navigate --side-by-side'            # 差分表示
alias grep='rg'                                         # grep

# システム操作
_CACHE_PATHS=(
  "/System/Library/Caches/*"
  "/Library/Caches/*"
  "/Library/Logs/*"
  "~/.cache/*"
  "~/Library/Caches/*"
  "~/Library/Metadata/*"
  "~/Library/Application\ Support/Code/Cache"
  "~/Library/Application\ Support/Code/CachedData"
)
alias cleanup='sudo rm -rf ${_CACHE_PATHS[@]} && brew cleanup'  # キャッシュをクリア
alias refresh='exec $SHELL -l'                                  # シェルを再起動
alias beep='afplay /System/Library/Sounds/Ping.aiff'            # ビープ音を再生

# Git
## フェッチ
alias gf='_git_fetch'
_git_fetch() {
  git fetch --all --prune --tags
}
## ブランチ切り替え
alias gb='_git_fetch && _git_checkout'
_git_checkout() {
  (
    # ローカルブランチを表示
    git branch -l --format='[L] %(refname:short)'
    # リモートブランチを表示
    git branch -r | grep -v HEAD | sed 's/^[ ]*origin\///' | sed 's/^/[R] /'
  ) | \
  # 重複するブランチを統合
  awk '{
      branch = $NF
      if (branch in seen) {
        print "[LR] " branch
        delete seen[branch]
      } else {
        seen[branch] = $0
      }
    } END {
      for (branch in seen) print seen[branch]
    }' | \
  sort | \
  fzf --header 'ENTER: checkout branch, ESC: cancel' | \
  sed -E 's/^\[(L|R|LR)\]\s*//' | \
  xargs -I{} sh -c 'git checkout {} && git pull origin {}'
}
## ログ表示
alias gl='_git_log'
_git_log() {
  git log --color=always --graph --abbrev-commit --pretty=format:'%C(dim yellow)%h%Creset -%C(auto)%d%Creset %s %C(dim blue)<%an> %C(dim green)(%aI)%Creset' | \
  fzf \
    --ansi \
    --preview 'f=$(echo {} | grep -o "[a-f0-9]\{7\}" | head -n1); if [ ! -z "$f" ]; then git show --color=always $f | delta --navigate --side-by-side --width ${FZF_PREVIEW_COLUMNS}; fi' \
    --preview-window 'bottom:70%' \
    --bind 'enter:ignore'
}
## 差分表示
alias gd="_git_diff"
_git_diff() {
  (
    echo '----- Staged -------------------------------------' && \
    git diff --color=always --stat --cached && \
    echo '----- Unstaged -----------------------------------' && \
    git diff --color=always --stat
  ) | \
  fzf \
    --ansi \
    --preview 'f=$(echo {} | sed -n '\''s/^[[:space:]]*\(.*\)[[:space:]]*|.*$/\1/p'\'' | grep -v '\''^[[-].*$'\'' | xargs); if [ ! -z "$f" ]; then (git diff --color=always "$f" | delta --navigate --side-by-side --width ${FZF_PREVIEW_COLUMNS}; git diff --color=always --cached "$f" | delta --navigate --side-by-side --width ${FZF_PREVIEW_COLUMNS}); fi' \
    --preview-window 'bottom:70%' \
    --bind 'enter:ignore'
  # fzf | \
  # sed -n 's/^[[:space:]]*\(.*\)[[:space:]]*|.*$/\1/p' | \
  # grep -v '^\[.*\]$' | \
  # xargs -I{} sh -c 'git diff {}; git diff --cached {}'
}
## スタッシュ適用
alias gs='_git_stash'
_git_stash() {
  # スタッシュの存在を確認
  if [ -z "$(git stash list)" ]; then
    echo 'no stashes found.'
    return 1
  fi

  # スタッシュ一覧を表示
  local stash=$(git stash list | \
    fzf --height 30% --reverse \
        --header 'ENTER: select stash, ESC: cancel' \
        --preview 'echo {} | grep -o "stash@{[0-9]\+}" | xargs git stash show -p | delta --navigate --side-by-side --width ${FZF_PREVIEW_COLUMNS}' \
        --preview-window 'bottom:70%')
  if [ -z "$stash" ]; then
    echo 'no stash selected.'
    return 1
  fi

  # 適用するスタッシュを確認
  echo 'apply this stash?'
  echo "  $stash"
  printf '  (y/n [n]): '
  if ! read -q; then
    echo 'operation cancelled.'
    return 0
  fi
  echo

  # スタッシュを適用
  local stash_id=$(echo $stash | \grep -o 'stash@{[0-9]\+}')
  echo "> git stash apply $stash_id"
  git stash apply "$stash_id"
}

# GCP
#alias gal='gcloud auth login'
#alias gaa='gcloud auth application-default login'
#alias gcl="gcloud config configurations list | \
#  fzf | \
#  cut -d ' ' -f 1 | \
#  xargs gcloud config configurations activate"

# Kubernetes
#alias k='kubectl'
#alias kc='kubectl config current-context'
#alias kcl="kubectl config get-contexts | \
#  fzf | \
#  sed 's/^[ \t*]*//' | \
#  cut -d ' ' -f 1 | \
#  xargs kubectl config use-context"

# 現在の Kubernetes Context を表示
#function kubectl-prompt() {
#  if [[ $ZSH_KUBECTL_PROMPT =~ ".* doesn't exist"$ ]]; then return 0; fi
#  if [[ $ZSH_KUBECTL_PROMPT != 'current-context is not set' ]]; then return 0; fi
#  echo "%{$bg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}"
#}
#export RPROMPT='$(kubectl-prompt)'


# ------------------------------------------------------------------------------
# キーバインド
# ------------------------------------------------------------------------------

function select-history() {
  BUFFER=$(\history -n -r 1 | fzf --query "$LBUFFER")
  CURSOR=$#BUFFER
}
zle -N select-history

bindkey '[C' forward-word    # option+Left:  単語左端へ移動
bindkey '[D' backward-word   # option+Right: 単語右端へ移動
bindkey '^R' select-history  # ctrl+R:       履歴検索


# ------------------------------------------------------------------------------
# hook 関数を実行
# ------------------------------------------------------------------------------

precmd() { eval $_PROMPT_COMMAND }


# ------------------------------------------------------------------------------
# その他ツール
# ------------------------------------------------------------------------------

# AWS CLI
# export PATH="$_BREW_PREFIX/bin/aws_completer:$PATH"
# complete -C "$_BREW_PREFIX/bin/aws_completer" aws

# Azure CLI
# source "$_BREW_PREFIX/etc/bash_completion.d/az"

# gcloud CLI
# source "$_BREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"
# source "$_BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"
