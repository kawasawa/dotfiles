#!/bin/sh
CURRENT_DIR=$(cd $(dirname $0) && pwd)
VSCODE_DIR=~/Library/Application\ Support/Code/User

# rc
for rc in .zshrc .vimrc
do cp "${HOME}/${rc}" "${CURRENT_DIR}/${rc}"; done

# VSCode
mkdir -p "${CURRENT_DIR}/vscode"
cp "${VSCODE_DIR}/settings.json" "${CURRENT_DIR}/vscode/settings.json"
cp "${VSCODE_DIR}/keybindings.json" "${CURRENT_DIR}/vscode/keybindings.json"
code --list-extensions > "${CURRENT_DIR}/vscode/extensions"
