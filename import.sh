#!/bin/sh
# set -euo pipefail

# ******************************************************************************
# インポート用スクリプト (macOS用)
# ******************************************************************************

# 本スクリプト内専用の変数を定義
_REPOS=$HOME/repos/dotfiles

# 本スクリプト内では常に以下を適用
#   Homebrew 自体の自動更新を抑制
#   明示的にやる場合は `brew upgrade`
export HOMEBREW_NO_AUTO_UPDATE=1
#   `brew install`, `brew bundle` 時にインストール済みアプリの自動更新を抑制
#   明示的にやる場合は `brew upgrade <アプリ名>`
export HOMEBREW_NO_INSTALL_UPGRADE=1
export HOMEBREW_BUNDLE_NO_UPGRADE=1

preProcess() {
    printf '\033[35m===============================================================================\033[m\n'
    printf '\033[35m===== Pre Process =============================================================\033[m\n'
    printf '\033[35m===============================================================================\033[m\n\n'

    # コマンドラインツールのセットアップ
    printf 'Setup command-line tools...\n'
    xcode-select --install
    softwareupdate --install-rosetta --agree-to-license
    printf 'done\n\n'

    # 本リポジトリ自体の clone
    if [ ! -e "$_REPOS" ]; then
        printf 'Clone git repository...\n'
        mkdir -p "$_REPOS"
        git clone https://github.com/kawasawa/dotfiles.git "$_REPOS"
        printf 'done\n\n'
    fi

    # Homebrew の導入
    if ! type brew > /dev/null 2>&1; then
        printf 'Installing Homebrew...\n'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        printf 'done\n\n'
    fi
    printf 'Apply Homebrew env var...\n'
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/bin:$PATH"
    printf 'done\n\n'
}

importDotfiles() {
    printf '\033[35m===============================================================================\033[m\n'
    printf '\033[35m===== Import ==================================================================\033[m\n'
    printf '\033[35m===============================================================================\033[m\n\n'


    printf '\033[35m----- Homebrew ----------------------------------------------------------------\033[m\n'

    if ! type brew > /dev/null 2>&1; then
        printf '[ERROR] brew not installed\n\n'
        exit 1
    fi

    # 管理対象ソフトフェアのインストール
    #   sudo 権限が必要な場合があり Ansible 内だと動作が不安定
    printf 'Install Homebrew packages...\n'
    brew bundle --file $_REPOS/packages/Brewfile
    rm -f Brewfile.lock.json
    printf 'done\n\n'


    printf '\033[35m----- chezmoi -----------------------------------------------------------------\033[m\n'

    if ! type chezmoi > /dev/null 2>&1; then
        printf '[ERROR] chezmoi not installed\n\n'
        exit 1
    fi

    # 管理対象設定ファイルの展開
    #   chezmoi は実行時に自身の設定を "~/.config/chezmoi/chezmoi.toml" から取得する
    #   しかし初回はこれが存在しないため、`--source` で本リポジトリを参照先として明示的に指定
    #   `init` により ".chezmoi.toml.tmpl" から "~/.config/chezmoi/chezmoi.toml" が生成され `sourceDir` で本リポジトリに辿り着ける
    #   これにより二回目以降は `chezmoi diff` / `chezmoi apply` 等をそのまま実行可能
    printf 'Run chezmoi...\n'
    chezmoi init --apply --source "$_REPOS"
    printf 'done\n\n'


    printf '\033[35m----- Ansible -----------------------------------------------------------------\033[m\n'

    if ! type ansible > /dev/null 2>&1; then
        printf '[ERROR] ansible not installed\n\n'
        exit 1
    fi

    # 構成管理を適用
    printf 'Run Ansible...\n'
    ansible-playbook $_REPOS/ansible.yml
    printf 'done\n\n'
}

main() {
    preProcess
    importDotfiles
    printf 'import completed\n'
}

main
exit 0
