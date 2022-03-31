#!/bin/sh

# ******************************************************************************
# エクスポート用スクリプト (macOS用)
# ******************************************************************************

_ROOT=$HOME/repos/dotfiles
_VSCODE_USER_DIR=~/Library/Application\ Support/Code/User

exportDotfiles() {
    printf '\033[35m----- dotfiles ----------------------------------------------------------------\033[m\n'

    # .gitconfig はアプリから固有の設定を書き込まれる場合があるため確認する
    echo 'export .gitconfig? (y/n [n]) \c'
    read -r -t 5 yn
    case "$yn" in
        [yY])
            printf 'Export Git Config...\n'
            cp "$HOME/.gitconfig" "$_ROOT/dotfiles/.gitconfig"
            printf 'done\n'
            ;;
        *)
            printf 'skipped\n'
            ;;
    esac
    printf '\n'

    printf 'Export .rc files...\n'
    for rc in "$_ROOT"/dotfiles/.*rc; do cp "$HOME/$(basename "$rc")" "$rc"; done
    printf 'done\n'

    printf '\n' # end
}

exportHomebrewApps() {
    printf '\033[35m----- Homebrew ----------------------------------------------------------------\033[m\n'

    printf 'Export Homebrew apps...\n'
    # ダンプを取るだけなので、さっさと終わらせるため自動更新を抑制
    HOMEBREW_NO_AUTO_UPDATE=1 brew bundle dump --force --file "$_ROOT/packages/Brewfile"
    # brew, cask, mas 以外は除外
    sed -i '' '/^vscode/d' "$_ROOT/packages/Brewfile"
    sed -i '' '/^go/d' "$_ROOT/packages/Brewfile"
    printf 'done\n'

    printf '\n' # end
}

exportMiseRuntimes() {
    printf '\033[35m----- mise --------------------------------------------------------------------\033[m\n'

    printf 'Export mise Runtimes...\n'
    cp -r "$HOME/.config/mise/config.toml" "$_ROOT/packages/mise.toml"
    printf 'done\n'

    printf '\n' # end
}

exportVSCodeConfig() {
    printf '\033[35m----- VSCode ------------------------------------------------------------------\033[m\n'

    printf 'Export VSCode Settings...\n'
    mkdir -p "$_ROOT/vscode"
    for vscode_config in "$_VSCODE_USER_DIR"/*.json; do
        [ -f "$vscode_config" ] || continue
        base_name=$(basename "$vscode_config" .json)
        cp "$vscode_config" "$_ROOT/vscode/${base_name}.jsonc"
    done

    mkdir -p "$_ROOT/vscode/prompts"
    cp -r "$_VSCODE_USER_DIR/prompts/." "$_ROOT/vscode/prompts/"
    cp -r "$HOME/.copilot/config.json" "$_ROOT/dotfiles/.copilot/config.json"

    code --list-extensions > "$_ROOT/packages/vscode"
    printf 'done\n'

    printf '\n' # end
}

main() {
    exportDotfiles
    exportHomebrewApps
    exportMiseRuntimes
    exportVSCodeConfig
}

main
