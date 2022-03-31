# dotfiles

【自分用】導入ツール、設定ファイル類をまとめたもの

## 構成

|                   | 管理ツール                                       | 設定ファイル                                                                   |
| ----------------- | ------------------------------------------------ | ------------------------------------------------------------------------------ |
| dotfiles 構成     | [Ansible](https://docs.ansible.com/)             | [ansible.yml](https://github.com/kawasawa/dotfiles/blob/main/ansible.yml)      |
| ソフトウェア      | [Homebrew](https://brew.sh/)                     | [Brewfile](https://github.com/kawasawa/dotfiles/blob/main/packages/Brewfile)   |
| ランタイム        | [mise](https://mise.jdx.dev/)                    | [mise.toml](https://github.com/kawasawa/dotfiles/blob/main/packages/mise.toml) |
| Zsh プラグイン    | [zplug](https://github.com/zplug/zplug)          | [.zshrc](https://github.com/kawasawa/dotfiles/blob/main/configs/.zshrc)       |
| Vim プラグイン    | [vim-plug](https://github.com/junegunn/vim-plug) | [.vimrc](https://github.com/kawasawa/dotfiles/blob/main/configs/.vimrc)       |
| VSCode プラグイン | -                                                | [vscode](https://github.com/kawasawa/dotfiles/blob/main/packages/vscode)       |

## 実行方法

### macOS

```sh
/bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/kawasawa/dotfiles/main/import.sh)"
```

### Windows

Windows 向けの設定は適当...

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

## そのほか

`.vscode/` を追跡対象から外しているが、必要であれば下記 `settings.json` を作成

```:json
{
    // フォーマッターの設定
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "eslint.workingDirectories": [{ "mode": "auto" }],

    // フォーマットルールを指定
    "files.insertFinalNewline": true,
    "files.trimFinalNewlines": true,
    "files.trimTrailingWhitespace": true,
    "[markdown]": { "files.trimTrailingWhitespace": false },

    // フォーマットタイミングを指定
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": { "source.fixAll.eslint": "explicit" }
}
```
