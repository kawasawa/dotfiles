#!/bin/sh
set -euo pipefail

# ******************************************************************************
# エクスポート用スクリプト (macOS用)
# ******************************************************************************

_REPOS=$HOME/repos/dotfiles

# 本スクリプト内では常に以下を適用
#   Homebrew 自体の自動更新を抑止
#   明示的にやる場合は `brew upgrade`
export HOMEBREW_NO_AUTO_UPDATE=1

exportConfigs() {
    printf '\033[35m===============================================================================\033[m\n'
    printf '\033[35m===== Configs =================================================================\033[m\n'
    printf '\033[35m===============================================================================\033[m\n\n'


    printf '\033[35m----- chezmoi -----------------------------------------------------------------\033[m\n'

    # 管理対象のファイルのみ退避
    #   新しく管理対象に追加する場合は `chezmoi add <path>` を手動実施
    printf 'Re-add dotfiles...\n'
    chezmoi re-add
    printf 'done\n\n'
}

exportPackages() {
    printf '\033[35m===============================================================================\033[m\n'
    printf '\033[35m===== Packages ================================================================\033[m\n'
    printf '\033[35m===============================================================================\033[m\n\n'


    printf '\033[35m----- Homebrew ----------------------------------------------------------------\033[m\n'

    printf 'Export Homebrew apps...\n'
    brew bundle dump --force --file "$_REPOS/packages/Brewfile"

    # brew, cask, mas 以外は除外
    sed -i '' '/^vscode/d' "$_REPOS/packages/Brewfile"
    sed -i '' '/^npm/d' "$_REPOS/packages/Brewfile"
    sed -i '' '/^go/d' "$_REPOS/packages/Brewfile"
    printf 'done\n\n'


    printf '\033[35m----- mise --------------------------------------------------------------------\033[m\n'

    printf 'Export mise runtimes...\n'
    cp -r "$HOME/.config/mise/config.toml" "$_REPOS/packages/mise.toml"
    printf 'done\n\n'


    printf '\033[35m----- VSCode ------------------------------------------------------------------\033[m\n'

    # 拡張機能の一覧のみ退避 (設定ファイルは chezmoi が管理しているため)
    printf 'Export VSCode extensions...\n'
    code --list-extensions > "$_REPOS/packages/vscode"
    printf 'done\n\n'
}

main() {
    exportConfigs
    exportPackages
    printf 'export completed\n'
}

main
