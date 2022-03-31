#!/bin/sh

# ******************************************************************************
# バックアップ用スクリプト (macOS用)
# ******************************************************************************

_DOTFILES=$HOME/repos/dotfiles

backupDotrc() {
    printf '\033[35m----- dotrc -------------------------------------------------------------------\033[m\n'

    for rc in "$_DOTFILES"/.*rc; do cp "$HOME/$(basename "$rc")" "$rc"; done
    cp "$HOME/.zprofile" "$_DOTFILES/.zprofile"
    printf 'done\n'

    printf '\n' # end
}

backupGitconfig() {
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
    cp "$_APP_VSCODE/keybindings.json" "$_DOTFILES_COMMON/vscode/keybindings.jsonc"
    cp "$_APP_VSCODE/mcp.json" "$_DOTFILES_COMMON/vscode/mcp.jsonc"
    mkdir -p "$_DOTFILES_COMMON/vscode/prompts"
    cp -r "$_APP_VSCODE/prompts/"* "$_DOTFILES_COMMON/vscode/prompts/"
    code --list-extensions > "$_DOTFILES_COMMON/vscode/extensions"
    printf 'done\n'

    printf '\n' # end
}

backupClaudeCodeComposition() {
    printf '\033[35m----- Claude Code -------------------------------------------------------------\033[m\n'

    _DOTFILES_COMMON="$(cd "$(dirname "$0")" && pwd)/common"
    _APP_CLAUDE="$HOME/.claude"

    mkdir -p "$_DOTFILES_COMMON/claude"
    # cp "$_APP_CLAUDE/CLAUDE.md" "$_DOTFILES_COMMON/claude/CLAUDE.md"
    cp "$_APP_CLAUDE/settings.json" "$_DOTFILES_COMMON/claude/settings.json"
    cp -r "$_APP_CLAUDE/commands" "$_DOTFILES_COMMON/claude/"

    printf 'done\n'

    printf '\n' # end
}

# backupSystemSettings() {
#     printf '\033[35m----- System ------------------------------------------------------------------\033[m\n'

#     _DOTFILES_MACOS_SYSTEM="$(cd "$(dirname "$0")" && pwd)/macos/system"

#     mkdir -p "$_DOTFILES_MACOS_SYSTEM"
#     lporg save --config "$_DOTFILES_MACOS_SYSTEM/launchpad.yml"
#     printf 'done\n'

#     printf '\n' # end
# }


main() {
    backupDotrc
    backupGitconfig
    backupBrewApplications
    backupVSCodeComposition
    backupClaudeCodeComposition
    # backupSystemSettings
}

main
