# ******************************************************************************
# Android 用プリインストールアプリ削除/復元ツール
# ------------------------------------------------------------------------------
# 引数
#   1. os : [必須] 対象の Android OS を指定する。
#   2. adb: 使用する adb の実行ファイルを明示する場合に指定する。
# ------------------------------------------------------------------------------
# 実行方法
# - macos
#   Homebrew で adb をインストールし、実行する。
#   ```pwsh
#   brew install --cask android-platform-tools
#   ./main.ps1 miui
#   ```
# - Windows
#   adb をダウンロードし、adb.exe のパスを指定して実行する。
#   (https://developer.android.com/studio/releases/platform-tools)
#   ```pwsh
#   ./main.ps1 miui -adb ./platform-tools/adb.exe
#   ```
# ******************************************************************************

# 引数の確認
Param([parameter(mandatory)]$os, [String]$adb)

$currentDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$applistPath = "${currentDir}/${os}"
if ((Test-Path $applistPath) -ne "True") {
  Write-Host "[ERROR] '$os' is not supported"
  return
}

if ([string]::IsNullOrEmpty($adb)) {
  $adb = "adb"
}
else {
  if ((Test-Path $adb) -ne "True") {
    Write-Host "[ERROR] '$adb' is not found"
    return
  }
}

# コマンドの選択
$choiceDescription = "System.Management.Automation.Host.ChoiceDescription"
$case0 = New-Object $choiceDescription("&List", "list")
$case1 = New-Object $choiceDescription("&Uninstall", "uninstall")
$case2 = New-Object $choiceDescription("&Reinstall", "reinstall")
$choice = [System.Management.Automation.Host.ChoiceDescription[]]($case0, $case1, $case2)
$select = $host.ui.PromptForChoice("select the command.", "", $choice, 0)
switch ($select) {
  1 {
    $command = "shell pm uninstall -k --user 0"
  }
  2 {
    $command = "shell cmd package install-existing"
  }
  default {
    $command = "shell pm list packages | sort"
  }
}

# リストの場合は表示して終了
if ($select -eq 0) {
  Start-Process -FilePath "${adb}" -ArgumentList "${command}" -Wait -NoNewWindow
  Write-Host "done"
  return
}

# 実行前の確認
$title = "Do you want to proceed with the following settings?"
$message = "  adb: ${adb}`r`n  command: ${command}`r`n  os: ${os}"
$yes = New-Object $choiceDescription("&Yes", "Yes")
$no = New-Object $choiceDescription("&No", "Mo")
$choice = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
if ($host.ui.PromptForChoice($title, $message, $choice, 0) -ne 0) {
  Write-Host "canceled"
  return
}

# コマンドの実行
$applications = Get-Content $applistPath
for ($i = 0; $i -lt $applications.Count; $i++) {
  $app = $applications[$i]
  Write-Host -NoNewline "[${i}] ${app}: "
  Start-Process -FilePath "${adb}" -ArgumentList "${command} ${app}" -Wait -NoNewWindow
}
Write-Host "done"
