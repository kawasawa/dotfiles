# dotfiles

【自分用】設定ファイル、環境構築ツール

## 実行方法

### macOS

    ```sh
    xcode-select --install
    softwareupdate --install-rosetta
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/kawasawa/dotfiles/main/install.sh)"
    ```

### Windows

    ```pwsh
    set-executionpolicy remotesigned
    set-executionpolicy -scope process -executionpolicy bypass
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/kawasawa/dotfiles/main/native/windows/Wingetfile" -OutFile "./Wingetfile"; & Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/kawasawa/dotfiles/main/native/windows/install.ps1" -OutFile "./install.ps1"; & "./install.ps1"
    ```

fnm の初期設定と Node.js, Yarn のインストール

    ```pwsh
    if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
    Add-Content -Path $PROFILE -Value "`nfnm env --use-on-cd | Out-String | Invoke-Expression"
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
    fnm install ${インストールする Node.js のバージョン `fnm list-remote` で確認}
    npm install -g yarn
    ```

## そのほか

`.vscode/` を追跡対象から外しているが、必要であれば下記 `settings.json` を作成すると良い。

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
