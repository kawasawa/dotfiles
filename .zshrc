# ******************************************************************************
# .zshrc
#
# ------------------------------------------------------------------------------
# TODO: 事前に下記を実施する
#   ```:sh
#   $ git clone https://github.com/zplug/zplug ~/.zplug
#   $ brew install zplug
#   $ brew install peco
#   $ brew install anyenv
#   ```
#
# NOTE: 初回起動時にプラグインがインストールされるため、下記で `y` を入力する
#   ```:sh
#   ...
#   - zplug/zplug: not installed
#   install plugins? (y/n [n]): _
#   ```
# ******************************************************************************

export LANG=ja_JP.utf-8
export LESSCHARSET=utf-8
export PATH=$HOME:$PATH

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# anyenv
eval "$(anyenv init -)"

# zplug
source ~/.zplug/init.zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug 'dracula/zsh', as:theme
zplug 'zsh-users/zsh-syntax-highlighting'
zplug 'chrissicool/zsh-256color'
zplug 'zsh-users/zsh-history-substring-search'
zplug 'zsh-users/zsh-autosuggestions'
zplug 'superbrothers/zsh-kubectl-prompt'
zplug 'zsh-users/zsh-completions'
zplug 'mafredri/zsh-async'
if ! zplug check --verbose; then
  printf 'install plugins? (y/n [n]): '
  if read -q; then
    echo; zplug install
  fi
fi
zplug load

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# GCP
export USE_GKE_GCLOUD_AUTH_PLUGIN=True


# ---------- テーマ設定 ----------
export ZSH_THEME='dracula'                            # テーマを適用


# ---------- プロンプト ----------
setopt prompt_subst                                   # プロンプト内の変数を展開
setopt no_beep                                        # ビープ音を無効化
setopt numeric_glob_sort                              # 自然順ソートを有効化
setopt interactive_comments                           # コメント識別を有効化
function add-newline() {                              # 空行を追加する関数
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then PS1_NEWLINE_LOGIN=true;
  else printf '\n';
  fi
}
PROMPT_COMMAND="add-newline; $PROMPT_COMMAND"         # 実行のたびに空行を追加


# ---------- 入力補完 ----------
autoload -Uz compinit; compinit                       # 入力補完を有効化
setopt correct                                        # スペル訂正を有効化
setopt complete_in_word                               # 入力途中でも補完候補を表示
setopt list_packed                                    # 補完候補の余白を縮小
setopt magic_equal_subst                              # 引数での補完を有効化
zstyle ':completion:*:default' menu select=1          # 補完候補のカーソル選択
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # 補完候補に大文字の要素を追加
zstyle ':completion:*' list-colors "$LS_COLORS"       # ファイル候補のカラー表示


# ---------- 履歴管理 ----------
export HISTFILE=~/.zsh_history                        # 履歴を保存するファイル
export HISTSIZE=1000                                  # メモリに保存される履歴数
export SAVEHIST=100000                                # ファイルに保存される履歴数
setopt inc_append_history                             # プロセスを横断して履歴を追記
setopt share_history                                  # プロセス間で履歴を常時共有
setopt hist_ignore_all_dups                           # 最新以外の重複した履歴を除去
setopt hist_ignore_dups                               # 直前と同一のコマンドは除外
setopt hist_reduce_blanks                             # 空コマンドは除外


# ---------- 補助表示 ----------
# Kubernetes Context
function kubectl-prompt() {
  if [[ "$ZSH_KUBECTL_PROMPT" =~ ".* doesn't exist"$ ]]; then return 0; fi
  if [[ "$ZSH_KUBECTL_PROMPT" != 'current-context is not set' ]]; then return 0; fi
  echo "%{$bg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}"
}
export RPROMPT='$(kubectl-prompt)'


# ---------- ショートカット ----------
# 履歴検索
function select-history() {
  BUFFER=$(\history -n -r 1 | peco --query "${LBUFFER}")
  CURSOR=$#BUFFER
}
zle -N select-history

# ワークスペース遷移 (VSCode)
function change-workspace() {
  WORK_SPACE=${HOME}/repos
  LIST=$(find ${WORK_SPACE} -type d -mindepth 1 -maxdepth 1)
  TARGET=$(echo ${LIST} | sed "s|^${WORK_SPACE}||" | peco)
  if [[ ${TARGET} == /* ]]; then
    echo "${TARGET} selected"
    code -r ${WORK_SPACE}${TARGET}
  fi
}
zle -N change-workspace


# ---------- エイリアス ----------
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias cp='cp -i'   # 上書き前に確認実施
alias mv='mv -i'   # 上書き前に確認実施
alias rm='rm -i'   # 削除前に確認実施
alias la='ls -a'   # 全ファイルを表示
alias ll='ls -l'   # 詳細情報を表示
alias lla='ls -la' # 全ファイルの詳細情報を表示
alias reload='exec $SHELL -l' # シェルを再起動
alias disk='smartctl -a /dev/disk0' # ストレージの情報
alias clean='sudo rm -rf /System/Library/Caches/* /Library/Caches/* ~/Library/Caches/* && brew cleanup' # キャッシュファイルを削除

# Kubernetes
alias kk='k9s'
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias kc='kubectl config current-context'
alias kcl='kubectl config get-contexts | peco | \
  sed "s/^[ \t*]*//" | cut -d " " -f 1 | \
  xargs kubectl config use-context'

# GCP
alias g='gcloud'
alias gl='gcloud auth login'
alias gal='gcloud auth application-default login'
alias gc='gcloud config list'
alias gcl='gcloud config configurations list | peco | \
  cut -d " " -f 1 | \
  xargs gcloud config configurations activate'


# ---------- キーバインド ----------
bindkey '[C' forward-word     # Option+Left:  単語左端へ移動
bindkey '[D' backward-word    # Option+Right: 単語右端へ移動
bindkey '^R' select-history   # Ctrl+R:       履歴検索
bindkey '^V' change-workspace # Ctrl+V:       ワークスペース遷移


# ---------- hook 関数を実行 ----------
precmd() { eval "$PROMPT_COMMAND" }
