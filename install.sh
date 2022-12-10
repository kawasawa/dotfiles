#!/bin/sh
CURRENT_DIR=$(cd $(dirname $0) && pwd)
VSCODE_DIR=~/Library/Application\ Support/Code/User

# rc
for rc in .zshrc .vimrc
do cp -i "${CURRENT_DIR}/${rc}" "${HOME}/${rc}"; done

# VSCode
cp -i "${CURRENT_DIR}/vscode/settings.json" "${VSCODE_DIR}/settings.json"
cp -i "${CURRENT_DIR}/vscode/keybindings.json" "${VSCODE_DIR}/keybindings.json"
read -p "install extensions? (y/n [n]): " yn
if [[ $yn == [yY] ]]; then
    cat "${CURRENT_DIR}/vscode/extensions" | while read line; do code --install-extension $line; done
else
    echo "not install"
fi
