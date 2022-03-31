#!/bin/sh

# ******************************************************************************
# エクスポート用スクリプト (macOS用)
# ******************************************************************************

_ROOT=$HOME/repos/dotfiles
_VSCODE_USER_DIR=~/Library/Application\ Support/Code/User

exportDotfiles() {
    printf '\033[35m----- dotfiles ----------------------------------------------------------------\033[m\n'

    # Git
    # .gitconfig はアプリから固有の設定を書き込まれる場合があるため確認する
    echo 'export .gitconfig? (y/n [n]) \c'
    read -r -t 5 yn
    case "$yn" in
        [yY])
            printf 'Export Git Config...\n'
            cp "$HOME/.gitconfig" "$_ROOT/home/.gitconfig"
            printf 'done\n'
            ;;
        *)
            printf 'skipped\n'
            ;;
    esac
    printf '\n'

    # .rc (Zsh も含まれる)
    printf 'Export .rc files...\n'
    for rc in "$_ROOT"/home/.*rc; do cp "$HOME/$(basename "$rc")" "$rc"; done
    printf 'done\n'

    # OpenCode
    printf 'Export OpenCode config...\n'
    mkdir -p "$_ROOT/home/dot_config/opencode"
    for f in "$_ROOT/home/dot_config/opencode"/*; do
        [ -f "$f" ] || continue
        base_name=$(basename "$f")
        if [ -f "$HOME/.config/opencode/$base_name" ]; then
            cp "$HOME/.config/opencode/$base_name" "$f"
        fi
    done
    printf 'done\n'

    # Ghostty
    printf 'Export Ghostty config...\n'
    mkdir -p "$_ROOT/home/Library/ghostty"
    cp -r "$HOME/Library/Application Support/com.mitchellh.ghostty/." "$_ROOT/home/Library/ghostty/"  # 指定フォルダ配下を丸ごとコピー
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
    sed -i '' '/^npm/d' "$_ROOT/packages/Brewfile"
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

exportClaudeCodeConfig() {
    printf '\033[35m----- Claude Code --------------------------------------------------------------\033[m\n'

    printf 'Export Claude Code config...\n'
    mkdir -p "$_ROOT/home/dot_claude"

    # 同名の設定ファイルをエクスポート
    for f in "$_ROOT/home/dot_claude"/*; do
        [ -f "$f" ] || continue
        base_name=$(basename "$f")
        if [ -f "$HOME/.claude/$base_name" ]; then
            cp "$HOME/.claude/$base_name" "$f"
        fi
    done

    # 同名のサブフォルダをエクスポート
    for d in "$_ROOT/home/dot_claude"/*/; do
        [ -d "$d" ] || continue
        dir_name=$(basename "$d")
        if [ -d "$HOME/.claude/$dir_name" ]; then
            rm -rf "$d"
            cp -r "$HOME/.claude/$dir_name" "$d"
        fi
    done
    printf 'done\n'

    printf '\n' # end
}

exportVSCodeConfig() {
    printf '\033[35m----- VSCode ------------------------------------------------------------------\033[m\n'

    printf 'Export VSCode Settings...\n'

    # GitHub Copilot
    mkdir -p "$_ROOT/home/dot_copilot"
    cp -r "$HOME/.copilot/settings.json" "$_ROOT/home/dot_copilot/settings.json"

    # 拡張子を jsonc に変換して退避
    mkdir -p "$_ROOT/home/Library/vscode"
    for vscode_config in "$_VSCODE_USER_DIR"/*.json; do
        [ -f "$vscode_config" ] || continue
        base_name=$(basename "$vscode_config" .json)
        cp "$vscode_config" "$_ROOT/home/Library/vscode/${base_name}.jsonc"
    done

    # 同名のサブフォルダをエクスポート
    for d in "$_ROOT/home/Library/vscode"/*/; do
        [ -d "$d" ] || continue
        dir_name=$(basename "$d")
        if [ -d "$_VSCODE_USER_DIR/$dir_name" ]; then
            rm -rf "$d"
            cp -r "$_VSCODE_USER_DIR/$dir_name" "$d"
        fi
    done

    # 拡張機能をリスト化して退避
    code --list-extensions > "$_ROOT/packages/vscode"
    printf 'done\n'

    printf '\n' # end
}

main() {
    exportDotfiles
    exportHomebrewApps
    exportMiseRuntimes
    exportClaudeCodeConfig
    exportVSCodeConfig
}

main
