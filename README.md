# dotfiles

【自分用】設定ファイル、環境構築ツール

## macOS

    ```sh
    xcode-select --install
    softwareupdate --install-rosetta
    /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/kawasawa/dotfiles/main/install.sh)"
    ```

## Windows

    ```pwsh
    set-executionpolicy remotesigned
    set-executionpolicy -scope process -executionpolicy bypass
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/kawasawa/dotfiles/main/Wingetfile" -OutFile "./Wingetfile"; & Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/kawasawa/dotfiles/main/install.ps1" -OutFile "./install.ps1"; & "./install.ps1"
    ```

fnm の初期設定と Node.js, Yarn のインストール

    ```pwsh
    New-Item $PROFILE -Force -Value "fnm env --use-on-cd | Out-String | Invoke-Expression”
    fnm install ${インストールする Node.js のバージョン `fnm list-remote` で確認}
    npm install -g yarn
    ```
