#!/bin/sh

# ******************************************************************************
# インポート用スクリプト (macOS用)
# ******************************************************************************

# 本スクリプト内専用の変数を定義
_ROOT=$HOME/repos/dotfiles
_CHEZMOI_CONFIG_DIR=$HOME/.config/chezmoi

# 本スクリプト内では常に以下を適用
#   Homebrew 自体の自動更新を抑止
#   明示的にやる場合は `brew upgrade`
export HOMEBREW_NO_AUTO_UPDATE=1
#   `brew install` `brew bundle` 時にインストール済みアプリを upgrade しない
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

    # Homebrew の導入
    if ! type brew > /dev/null 2>&1; then
        printf 'Installing Homebrew...\n'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        printf 'done\n\n'
    else
        printf 'Homebrew already installed\n\n'
    fi
    printf 'Apply Homebrew env var...\n'
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/bin:$PATH"
    printf 'done\n\n'

    # 本リポジトリ自体の clone
    if [ ! -e "$_ROOT" ]; then
        printf 'Clone git repository...\n'
        mkdir -p "$_ROOT"
        git clone https://github.com/kawasawa/dotfiles.git "$_ROOT"
        printf 'done\n\n'
    else
        printf 'Git repository already exists\n\n'
    fi

    printf 'done\n\n'
}

process() {
    printf '\033[35m===============================================================================\033[m\n'
    printf '\033[35m===== Main Process ============================================================\033[m\n'
    printf '\033[35m===============================================================================\033[m\n\n'

    printf '\033[35m----- chezmoi -----------------------------------------------------------------\033[m\n'

    # chezmoi のインストール
    printf 'Installing chezmoi...\n'
    brew install chezmoi
    printf 'done\n\n'

    # chezmoi 用 config を生成
    #   chezmoi は起動時に指定の config ファイルを要求するため事前生成する
    #   管理ディレクトリを本リポジトリに変更 (default: ~/.local/share/chezmoi/)
    printf 'Configure chezmoi...\n'
    mkdir -p "$_CHEZMOI_CONFIG_DIR"
    cat > "$_CHEZMOI_CONFIG_DIR/chezmoi.toml" <<EOF
# 本ファイルは手動編集しないこと
sourceDir = "$_ROOT"
EOF
    printf 'done\n\n'

    # 設定ファイルを展開
    printf 'Run chezmoi...\n'
    chezmoi apply
    printf 'done\n\n'


    printf '\033[35m----- Ansible -----------------------------------------------------------------\033[m\n'

    # Ansible のインストール
    printf 'Installing Ansible...\n'
    brew install ansible
    printf 'done\n\n'

    # 依存ツールを事前導入しておく
    printf 'Preparing for Ansible Playbook...\n'
    brew install mise
    brew install visual-studio-code
    printf 'done\n\n'

    # 構成管理を適用
    printf 'Run Ansible...\n'
    ansible-playbook $_ROOT/ansible.yml
    printf 'done\n\n'


    printf '\033[35m----- Homebrew ----------------------------------------------------------------\033[m\n'

    # 管理対象ソフトフェアのインストール (インストール済みのものは更新しない)
    #   sudo 権限が必要な場合があり Ansible 内だと動作が不安定だった
    printf 'Install Homebrew packages...\n'
    brew bundle --file $_ROOT/packages/Brewfile
    rm -f Brewfile.lock.json
    printf 'done\n\n'
}

postProcess() {
    printf '\033[35m===============================================================================\033[m\n'
    printf '\033[35m===== Post Process ============================================================\033[m\n'
    printf '\033[35m===============================================================================\033[m\n\n'

    # 依存ツールを事前導入しておく
    printf 'Preparing for Ansible Playbook...\n'
    brew install duti
    printf 'done\n\n'

    # 構成管理を適用 (macOS 依存)
    printf 'Run Ansible...\n'
    ansible-playbook $_ROOT/native/macos/ansible.yml
    printf 'done\n\n'
}

main() {
    preProcess
    process
    postProcess
    printf 'import completed\n'
}

main
