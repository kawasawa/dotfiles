# ******************************************************************************
# インストール用スクリプト (Windows用)
# ******************************************************************************

$directory = Split-Path $MyInvocation.MyCommand.Path -Parent
$applications = Get-Content "$directory/Wingetfile"
Write-Output "------------------------------"
Write-Output $applications
Write-Output "------------------------------"

$choiceDescription = "System.Management.Automation.Host.ChoiceDescription"
$yes = New-Object $choiceDescription("&Yes", "Yes")
$no = New-Object $choiceDescription("&No", "No")
$choice = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
if ($host.ui.PromptForChoice("install winget applications?", "", $choice, 1) -ne 0) {
    Write-Output "not install"
    return
}

foreach ($app in $applications) {
    Write-Output "install: $app"
    & winget install --exact --id $app
    if ($LastExitCode -ne 0) {
        Write-Output "[ERROR] aborted: $app`n"
        continue
    }
    Write-Output "completed: $app`n"
}
Write-Output "done"
