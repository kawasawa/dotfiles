#!/bin/sh

# ******************************************************************************
# インポート用スクリプト (macOS用)
# ******************************************************************************

_ROOT=$HOME/repos/dotfiles

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

    # Homebrew のインストール
    printf '\033[35m----- Homebrew ----------------------------------------------------------------\033[m\n'
    if ! type brew > /dev/null 2>&1; then
        printf 'Installing Homebrew...\n'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        printf 'done\n\n'
    else
        printf 'Homebrew already installed\n\n'
    fi

    # Ansible のインストール
    printf '\033[35m----- Ansible -----------------------------------------------------------------\033[m\n'
    if ! type ansible > /dev/null 2>&1; then
        printf 'Installing Ansible...\n'
        HOMEBREW_NO_AUTO_UPDATE=1 brew install ansible
        printf 'done\n\n'
    else
        printf 'Ansible already installed\n\n'
    fi

    # 環境変数の適用
    printf '\033[35m----- EnvVar ------------------------------------------------------------------\033[m\n'
    printf 'Apply EnvVar...\n'
    # Homebrew の環境変数を適用
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/bin:$PATH"
    printf 'done\n\n'

    # 環境設定の実施
    printf '\033[35m----- Configure ---------------------------------------------------------------\033[m\n'
    printf 'Run Ansible...\n'
    ansible-playbook ansible.yml
    printf 'done\n\n'
}

postProcess() {
    printf '\033[35m===============================================================================\033[m\n'
    printf '\033[35m===== Post Process ============================================================\033[m\n'
    printf '\033[35m===============================================================================\033[m\n\n'

    printf 'Run Ansible...\n'
    ansible-playbook native/macos/ansible.yml
    printf 'done\n\n'
}

main() {
    preProcess
    process
    postProcess
    printf 'Setup completed\n'
}

main
