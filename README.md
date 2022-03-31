# dotfiles

【自分用】導入ツール、設定ファイル類をまとめたもの (macOS 向け、だいぶ適当)

## 構成

| 管理対象         | 制御ツール                                       | 定義ファイル                                  |
| ---------------- | ------------------------------------------------ | --------------------------------------------- |
| macOS            | [Ansible](https://docs.ansible.com/)             | [ansible.yml](./ansible.yml)                  |
| Configs          | [chezmoi](https://www.chezmoi.io/)               | [.chezmoi.toml](./configs/.chezmoi.toml.tmpl) |
| AI Dependencies  | [APM](https://github.com/microsoft/apm)          | [apm.yml](./configs/dot_apm/apm.yml)          |
| Applications     | [Homebrew](https://brew.sh/)                     | [Brewfile](./packages/Brewfile)               |
| Runtimes         | [mise](https://mise.jdx.dev/)                    | [mise.toml](./packages/mise.toml)             |
| Plugins (Zsh)    | [zplug](https://github.com/zplug/zplug)          | [.zshrc](./configs/dot_zshrc)                 |
| Plugins (Vim)    | [vim-plug](https://github.com/junegunn/vim-plug) | [.vimrc](./configs/dot_vimrc)                 |
| Plugins (VSCode) | -                                                | [vscode](./packages/vscode)                   |

## 実行方法

### インポート

```sh
/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/kawasawa/dotfiles/main/import.sh)"
```

### アップデート

```sh
# リポジトリ側の変更を端末に適用
./import.sh
```

- 一部だけ適用するなら

  ```sh
  # brew のみ
  brew bundle --file packages/Brewfile

  # chezmoi のみ
  chezmoi apply

  # ansible のみ
  ansible-playbook ansible.yml
  ```

### エクスポート

```sh
# 端末側の変更をリポジトリに退避
./export.sh
```

以上
