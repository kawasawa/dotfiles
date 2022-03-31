#!/bin/sh

# ******************************************************************************
# バックアップ用スクリプト (macOS用)
# ******************************************************************************

_DOTFILES=$HOME/repos/dotfiles

backupGit() {
    printf '\033[35m----- Git ---------------------------------------------------------------------\033[m\n'

    # .gitconfig はアプリから固有の設定を書き込まれる場合があるため確認する
    echo 'backup .gitconfig? (y/n [n]) \c'
    read -r -t 5 yn
    case "$yn" in
        [yY])
            cp "$HOME/.gitconfig" "$_DOTFILES/.gitconfig"
            printf '\ndone\n'
            ;;
    esac

    printf '\n' # end
}

backupDotRc() {
    printf '\033[35m----- .rc ---------------------------------------------------------------------\033[m\n'

    for rc in "$_DOTFILES"/.*rc; do cp "$HOME/$(basename "$rc")" "$rc"; done
    printf 'done\n'

    printf '\n' # end
}

backupBrewApps() {
    printf '\033[35m----- Homebrew ----------------------------------------------------------------\033[m\n'

    # ダンプを取るだけなので、さっさと終わらせるため自動更新を抑制
    HOMEBREW_NO_AUTO_UPDATE=1 brew bundle dump --force --file "$_DOTFILES/Brewfile"
    # vscode の拡張機能は別で管理するため除去
    sed -i '' '/^vscode/d' "$_DOTFILES/Brewfile"
    printf 'done\n'

    printf '\n' # end
}

backupVSCode() {
    printf '\033[35m----- VSCode ------------------------------------------------------------------\033[m\n'

    _PWD="$(cd "$(dirname "$0")" && pwd)"
    _APP_VSCODE=~/Library/Application\ Support/Code/User

    mkdir -p "$_PWD/vscode"
    cp "$_APP_VSCODE/settings.json" "$_PWD/vscode/settings.jsonc"
    cp "$_APP_VSCODE/keybindings.json" "$_PWD/vscode/keybindings.jsonc"
    cp "$_APP_VSCODE/mcp.json" "$_PWD/vscode/mcp.jsonc"
    mkdir -p "$_PWD/vscode/prompts"
    cp -r "$_APP_VSCODE/prompts/"* "$_PWD/vscode/prompts/"
    code --list-extensions > "$_PWD/vscode/extensions"
    printf 'done\n'

    printf '\n' # end
}

main() {
    backupGit
    backupDotRc
    backupBrewApps
    backupVSCode
}

main
