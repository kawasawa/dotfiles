#!/bin/sh

# ******************************************************************************
# バックアップ用スクリプト (macOS用)
# ******************************************************************************

_DOTFILES=$HOME/repos/dotfiles

backupDotrc() {
    printf '\033[35m----- dotrc -------------------------------------------------------------------\033[m\n'

    for rc in "$_DOTFILES"/.*rc; do cp "$HOME/$(basename "$rc")" "$rc"; done
    printf 'done\n'

    printf '\n' # end
}

backupGitconfig() {
    printf '\033[35m----- Git ---------------------------------------------------------------------\033[m\n'

    cp "$HOME/.config/git/config" "$_DOTFILES/.gitconfig"
    printf 'done\n'

    printf '\n' # end
}

backupBrewApplications() {
    printf '\033[35m----- Homebrew ----------------------------------------------------------------\033[m\n'

    brew bundle dump --force --file "$_DOTFILES/Brewfile"
    # vscode の拡張機能は別で管理するため除去
    sed -i '' '/^vscode/d' "$_DOTFILES/Brewfile"
    printf 'done\n'

    printf '\n' # end
}

backupVSCodeComposition() {
    printf '\033[35m----- VSCode ------------------------------------------------------------------\033[m\n'

    _DOTFILES_COMMON="$(cd "$(dirname "$0")" && pwd)/common"
    _APP_VSCODE=~/Library/Application\ Support/Code/User

    mkdir -p "$_DOTFILES_COMMON/vscode"
    cp "$_APP_VSCODE/settings.json" "$_DOTFILES_COMMON/vscode/settings.jsonc"
    cp "$_APP_VSCODE/keybindings.json" "$_DOTFILES_COMMON/vscode/keybindings_macos.jsonc"
    code --list-extensions > "$_DOTFILES_COMMON/vscode/extensions"
    printf 'done\n'

    printf '\n' # end
}

main() {
    backupDotrc
    backupGitconfig
    backupBrewApplications
    backupVSCodeComposition
}

main