#!/bin/sh

# ******************************************************************************
# インポート用スクリプト (macOS用)
# ******************************************************************************

_ROOT=$HOME/repos/dotfiles
_VSCODE_USER_DIR=~/Library/Application\ Support/Code/User

preProcess() {
    printf '\033[35m===============================================================================\033[m\n'
    printf '\033[35m===== Pre Process =============================================================\033[m\n'
    printf '\033[35m===============================================================================\033[m\n\n'

    xcode-select --install
    softwareupdate --install-rosetta --agree-to-license
    printf 'done\n\n'
}

process() {
    printf '\033[35m===============================================================================\033[m\n'
    printf '\033[35m===== Main Process ============================================================\033[m\n'
    printf '\033[35m===============================================================================\033[m\n\n'

    # パッケージ管理の導入
    printf '\033[35m----- Homebrew ----------------------------------------------------------------\033[m\n'
    if ! type brew > /dev/null 2>&1; then
        printf 'Installing Homebrew...\n'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        printf 'done\n\n'
    else
        printf 'Homebrew already installed\n\n'
    fi

    # Homebrew の環境変数を適用
    printf 'Apply EnvVar...\n'
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/bin:$PATH"
    printf 'done\n\n'

    # リポジトリのクローン
    printf '\033[35m----- Repository --------------------------------------------------------------\033[m\n'

    if [ ! -e "$_ROOT" ]; then
        printf 'Clone repository...\n'
        mkdir -p "$_ROOT"
        git clone https://github.com/kawasawa/dotfiles.git "$_ROOT"
        printf 'done\n\n'
    else
        printf 'Repository already exists\n\n'
    fi

    # 構成管理の適用
    printf '\033[35m----- Ansible -----------------------------------------------------------------\033[m\n'
    if ! type ansible > /dev/null 2>&1; then
        printf 'Installing Ansible...\n'
        HOMEBREW_NO_AUTO_UPDATE=1 brew install ansible
        printf 'done\n\n'
    else
        printf 'Ansible already installed\n\n'
    fi

    # Playbook が依存するソフトウェアをインストールしておく
    printf 'Preparing for Ansible Playbook...\n'
    HOMEBREW_NO_AUTO_UPDATE=1 brew install yazi
    HOMEBREW_NO_AUTO_UPDATE=1 brew install mise
    HOMEBREW_NO_AUTO_UPDATE=1 brew install visual-studio-code
    printf 'done\n\n'

    # VSCode のユーザーディレクトリを作成（起動前だと存在しないため）
    if [ ! -e "$_VSCODE_USER_DIR" ]; then
        printf 'Create VSCode User Directory...\n'
        mkdir -p "$_VSCODE_USER_DIR"
        printf 'done\n\n'
    else
        printf 'VSCode User Directory already exists\n\n'
    fi

    # Ansible の実行
    printf 'Run Ansible...\n'
    ansible-playbook $_ROOT/ansible.yml
    printf 'done\n\n'

    # ソフトフェアのインストール
    # sudo 権限が必要な場合があり Ansible 側だと動作が安定しない
    printf '\033[35m----- Brewfile ----------------------------------------------------------------\033[m\n'
    printf 'Install Homebrew packages...\n'
    brew bundle --file $_ROOT/packages/Brewfile
    rm -f Brewfile.lock.json
    printf 'done\n\n'
}

postProcess() {
    printf '\033[35m===============================================================================\033[m\n'
    printf '\033[35m===== Post Process ============================================================\033[m\n'
    printf '\033[35m===============================================================================\033[m\n\n'

    printf 'Installing Software for Ansible Playbook...\n'
    HOMEBREW_NO_AUTO_UPDATE=1 brew install duti
    printf 'done\n\n'

    printf 'Run Ansible...\n'
    ansible-playbook $_ROOT/native/macos/ansible.yml
    printf 'done\n\n'
}

main() {
    preProcess
    process
    postProcess
    printf 'Setup completed\n'
}

main
