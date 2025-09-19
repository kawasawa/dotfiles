# dotfiles

【自分用】設定ファイル、環境構築ツール

## このdotfilesができること

このリポジトリは、macOSとWindowsでの開発環境を自動的にセットアップし、以下の機能を提供します：

### 🛠️ 開発ツールのインストールと設定
- **エディタ**: VS Code, Claude Code, MacVim, Vim の設定とプラグイン
- **ターミナル**: zsh + zplug による高機能シェル環境
- **Git**: 設定ファイルと便利なエイリアス
- **プログラミング言語**: Node.js, Python, Go, Terraform のランタイム管理

### 📦 アプリケーションの一括インストール
- **開発ツール**: Docker Desktop, Postman, JetBrains Toolbox, Sourcetree
- **クラウドツール**: AWS CLI, Azure CLI, Google Cloud CLI
- **データベース**: TablePlus
- **ブラウザとセキュリティ**: Google Chrome + AdGuard, Dark Reader
- **ユーティリティ**: Rectangle, Maccy, Keka, DeepL など

### ⚙️ システム設定の自動化
- **macOS**: キーリピート、隠しファイル表示、スクリーンショット設定の最適化
- **キーボード**: Karabiner-Elements による日本語入力の改善
- **ファイル関連づけ**: 適切なアプリケーションとの関連づけ設定

### 🔄 バックアップと同期
- 設定ファイルの自動バックアップ（`backup.sh`）
- VS Code、Claude Code の設定とプロンプトの同期
- dotfiles の継続的な管理と更新

### 🤖 AI 統合機能
- Claude Code との統合設定
- カスタムプロンプトとインストラクション
- コーディング規約の自動適用

### 🌐 多言語・多環境対応
- **macOS**: Homebrew によるパッケージ管理
- **Windows**: Winget によるアプリケーション管理
- **言語ランタイム**: mise による複数バージョン管理

## インストール方法

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
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/kawasawa/dotfiles/main/windows/Wingetfile" -OutFile "./Wingetfile"; & Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/kawasawa/dotfiles/main/windows/install.ps1" -OutFile "./install.ps1"; & "./install.ps1"
    ```

fnm の初期設定と Node.js, Yarn のインストール

    ```pwsh
    if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }
    Add-Content -Path $PROFILE -Value "`nfnm env --use-on-cd | Out-String | Invoke-Expression"
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
    fnm install ${インストールする Node.js のバージョン `fnm list-remote` で確認}
    npm install -g yarn
    ```

## インストールされるツールと言語

### プログラミング言語ランタイム
- **Node.js**: 18.14.2
- **Python**: 3.10.16
- **Go**: 1.22.12
- **Terraform**: 1.9.8

### コマンドラインツール
- **ファイル操作**: `bat`（cat代替）, `eza`（ls代替）, `ripgrep`（grep代替）
- **検索・フィルタ**: `fzf`（ファジーファインダー）, `jq`（JSON処理）
- **Git**: `git-delta`（diff改善）, `gh`（GitHub CLI）, `glab`（GitLab CLI）
- **クラウド**: `awscli`, `azure-cli`, `gcloud-cli`
- **コンテナ・オーケストレーション**: `docker-desktop`, `k6`, `k9s`
- **AI**: `ollama`（ローカルLLM）, `codex`

### 開発アプリケーション
- **エディタ・IDE**: Visual Studio Code, Claude Code, MacVim
- **データベース**: TablePlus
- **API**: Postman, Stoplight Studio
- **バージョン管理**: Sourcetree
- **ユーティリティ**: Cyberduck（FTP/SFTP）, Keka（アーカイブ）

### システム設定とカスタマイズ

#### macOS専用機能
- Karabiner-Elements によるキーボードカスタマイズ
- Launchpad の自動整理
- システム環境設定の最適化
- ファイル拡張子の関連づけ自動設定

#### Windows専用機能
- PowerShell の設定とプロファイル
- fnm による Node.js バージョン管理
- Sakuraエディタの設定

## 使い方

### 設定のバックアップ
現在の設定をリポジトリに保存：
```sh
./backup.sh
```

### 個別コンポーネントの管理
- VS Code設定: `common/vscode/` ディレクトリ
- Claude設定: `common/claude/` ディレクトリ  
- vim設定: `.vimrc`, `.gvimrc`
- zsh設定: `.zshrc`, `.zprofile`
