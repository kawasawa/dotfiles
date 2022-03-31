#!/bin/zsh

# ******************************************************************************
# インストール用スクリプト (macOS用)
# ******************************************************************************

_DOTFILES=$HOME/repos/dotfiles

downloadRepository() {
    printf '\033[35m----- repository --------------------------------------------------------------\033[m\n'

    if [ ! -e "$_DOTFILES" ]; then
        mkdir -p "$HOME/repos"
        git clone https://github.com/kawasawa/dotfiles.git "$_DOTFILES"
    else
        printf 'repository already exists\n'
    fi

    printf '\n' # end
}

migrateDotrc() {
    printf '\033[35m----- dotrc -------------------------------------------------------------------\033[m\n'

    # .xxxrc, zsh 系のみ移行する
    # 他は個別に確認する
    if [ ! -e "$HOME/.zplug" ]; then git clone https://github.com/zplug/zplug "$HOME/.zplug"; fi
    for rc in "$_DOTFILES"/.*rc; do cp -i "$rc" "$HOME/$(basename "$rc")"; done
    cp -i "$_DOTFILES/.zprofile" "$HOME/.zprofile"

    printf '\n' # end
}

migrateGitconfig() {
    printf '\033[35m----- Git ---------------------------------------------------------------------\033[m\n'

    echo 'migrate gitconfig? (y/n [n]): \c'
    read -r yn
    case "$yn" in
        [yY])
            mkdir -p "$HOME/.config/git"
            cp "$_DOTFILES/.gitconfig" "$HOME/.gitconfig"
            ;;
        * )
            printf 'not migrate\n'
            ;;
    esac

    # printf '\n> \033[36mgit config -l\033[m\n'
    # git config -l

    printf '\n' # end
}

installBrewApplications() {
    printf '\033[35m----- Homebrew ----------------------------------------------------------------\033[m\n'

    if ! type brew > /dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        printf 'Homebrew already installed\n'
    fi

    echo 'install brew applications? (y/n [n]): \c'
    read -r yn
    case "$yn" in
        [yY])
            brew bundle --file "$_DOTFILES/Brewfile"
            rm -f Brewfile.lock.json
            ;;
        * )
            printf 'not install\n'
            ;;
    esac

    printf '\n> \033[36mbrew list\033[m\n'
    brew list

    printf '\n' # end
}

installMiseRuntimes() {
    printf '\033[35m----- mise --------------------------------------------------------------------\033[m\n'

    printf '> \033[36mcat .tool-versions\033[m\n'
    cat "$_DOTFILES/.tool-versions"
    printf '\n'

    echo 'install mise runtimes? (y/n [n]): \c'
    read -r yn
    case "$yn" in
        [yY])
            while read -r _LINE || [ -n "${_LINE}" ]; do
                # shellcheck disable=SC2086
                # mise install $_LINE
                # shellcheck disable=SC2086
                # mise global $_LINE
                mise use $_LINE
            done < "$_DOTFILES/.tool-versions"
            ;;
        * )
            printf 'not install\n'
            ;;
    esac

    printf '\n> \033[36mmise plugin ls -u\033[m\n'
    mise plugin ls -u

    printf '\n> \033[36mmise ls -g\033[m\n'
    mise ls -g

    printf '\n' # end
}

migrateVSCodeComposition() {
    printf '\033[35m----- VSCode ------------------------------------------------------------------\033[m\n'

    echo 'migrate vscode settings? (y/n [n]): \c'
    read -r yn
    case "$yn" in
        [yY])
            _APP_VSCODE=~/Library/Application\ Support/Code/User
            cp "$_DOTFILES/common/vscode/settings.jsonc" "$_APP_VSCODE/settings.json"
            cp "$_DOTFILES/common/vscode/keybindings.jsonc" "$_APP_VSCODE/keybindings.json"
            cp "$_DOTFILES/common/vscode/mcp.jsonc" "$_APP_VSCODE/mcp.json"
            mkdir -p "$_APP_VSCODE/prompts"
            cp -r "$_DOTFILES/common/vscode/prompts/"*  "$_APP_VSCODE/prompts/"
            ;;
        * )
            printf 'not migrate\n'
            ;;
    esac

    echo 'install vscode extensions? (y/n [n]): \c'
    read -r yn
    case "$yn" in
        [yY])
            while read -r _LINE || [ -n "${_LINE}" ]; do
                code --install-extension "$_LINE"
            done < "$_DOTFILES/common/vscode/extensions"
            ;;
        * )
            printf 'not install\n'
            ;;
    esac

    printf '\n' # end
}

migrateClaudeCodeComposition() {
    printf '\033[35m----- Claude Code -------------------------------------------------------------\033[m\n'

    echo 'migrate claude code settings? (y/n [n]): \c'
    read -r yn
    case "$yn" in
        [yY])
            mkdir -p "$HOME/.claude"
            cp -r "$_DOTFILES/common/claude/"* "$HOME/.claude/"
            ;;
        * )
            printf 'not migrate\n'
            ;;
    esac

    printf '\n' # end
}

continueExtraSettings() {
    printf '\033[35m----- Extra -------------------------------------------------------------------\033[m\n'

    echo 'would you like to continue to set up the environment dependencies? (y/n [n]): \c'
    read -r yn
    case "$yn" in
        [yY])
            # システム設定
            # キーのリピート入力を有効化
            defaults write -g ApplePressAndHoldEnabled -boolean false
            # 既定で隠しファイルを表示
            defaults write com.apple.Finder AppleShowAllFiles -boolean true; killall Finder
            # スクリーンショットのシャドウを除去
            defaults write com.apple.screencapture disable-shadow -boolean true; killall SystemUIServer
            printf 'system settings... done\n'

            # LaunchPad と Dock の設定
            defaults delete com.apple.dock persistent-apps
            defaults delete com.apple.dock persistent-others
            # Dock にアプリを固定したい場合は
            # while read -r _LINE || [ -n "${_LINE}" ]; do
            #     defaults write com.apple.dock persistent-apps -array-add \
            #     "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$_LINE</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
            # done < "$_DOTFILES/macos/system/dockapps"
            # defaults write com.apple.dock tilesize -int 50
            #
            # macOS18以降右記エラーが出て途中で止まる...: failed to fix Other folder: group 'Other' not found
            # lporg load --config "$_DOTFILES/macos/system/launchpad.yml" --no-backup --yes
            killall Dock
            printf 'dock apps... done\n'

            # 拡張子の関連づけ
            while read -r _LINE || [ -n "${_LINE}" ]; do
                # duti -s com.coteditor.CotEditor $_LINE all
                duti -s org.vim.MacVim $_LINE all
            done < "$_DOTFILES/macos/system/associations_text"
            printf 'app associations... done\n'

            ;;

        * )
            printf 'not extra settings\n'
            ;;
    esac

    printf '\n' # end
}

main() {
    xcode-select --install
    downloadRepository
    migrateDotrc
    migrateGitconfig
    installBrewApplications
    installMiseRuntimes
    migrateVSCodeComposition
    migrateClaudeCodeComposition
    continueExtraSettings
    printf 'done'
}

main
