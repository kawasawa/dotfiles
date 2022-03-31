# dotfiles

【自分用】導入ツール、設定ファイル類をまとめたもの (だいぶ適当)

## 構成

| 管理対象         | 制御ツール                                       | 定義ファイル                                                         |
| ---------------- | ------------------------------------------------ | -------------------------------------------------------------------- |
| OS, Packages     | [Ansible](https://docs.ansible.com/)             | [ansible.yml](./ansible.yml), [(native)](./native/macos/ansible.yml) |
| Applications     | [Homebrew](https://brew.sh/)                     | [Brewfile](./packages/Brewfile)                                      |
| Runtimes         | [mise](https://mise.jdx.dev/)                    | [mise.toml](./packages/mise.toml)                                    |
| Configs          | [chezmoi](https://www.chezmoi.io/)               | -                                                                    |
| Plugins (Zsh)    | [zplug](https://github.com/zplug/zplug)          | [.chezmoiexternal.toml](./configs/.chezmoiexternal.toml)             |
| Plugins (Vim)    | [vim-plug](https://github.com/junegunn/vim-plug) | [dot_vimrc](./configs/dot_vimrc)                                     |
| Plugins (VSCode) | -                                                | [vscode](./packages/vscode)                                          |

## 実行方法

### macOS

#### インポート

```sh
/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/kawasawa/dotfiles/main/import.sh)"
```

#### アップデート

```sh
# リポジトリ側の変更を端末に適用
./import.sh
```

#### エクスポート

```sh
# 端末側の変更をリポジトリに退避
./export.sh
```

### Windows

Windows は気が向いたらなんとかする

```pwsh
# 実行ポリシーの設定
set-executionpolicy remotesigned
set-executionpolicy -scope process -executionpolicy bypass

# スクリプトの実行
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/kawasawa/dotfiles/main/native/windows/Wingetfile" -OutFile "./Wingetfile"; & Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/kawasawa/dotfiles/main/native/windows/import.ps1" -OutFile "./import.ps1"; & "./import.ps1"

# Node.js のインストール
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
Add-Content -Path $PROFILE -Value "`nfnm env --use-on-cd | Out-String | Invoke-Expression"
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
fnm install <インストールする Node.js のバージョン `fnm list-remote` で確認>
```

以上
