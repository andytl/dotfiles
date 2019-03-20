# Hello world (Dotfile backup test)

# Table of Contents
# Helper Functions [HLPR]
# VSTS Functions [VSTSF]
## Cosmos [CSMS]
## Coding [CDNG]

Set-StrictMode -Version Latest

$UserPSModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
if (-not $env:PSModulePath.Contains($UserPSModulePath)) {
    $env:PSModulePath += ";$UserPSModulePath"
}

# Imports=
Import-Module posh-git
Import-Module PSReadLine

Import-Module "Personal\Common" -Force 
# Work specific module if it exists
Import-Module "WorkSpecific\XflowDevelopment" -Force

# Setup PSReadLine
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Chord Ctrl+D -Function DeleteCharOrExit

# Setup Profile related items and aliases 
# Remove this alias, want to use the real deal.
if (Test-Path alias:curl) {
  Remove-Item alias:curl
}


Set-Alias np "C:\Program Files\Notepad++\notepad++.exe"
Set-Alias g git
Set-Alias cjson ConvertTo-Json
Set-Alias gclip Get-Clipboard

function flp ([Parameter(ValueFromPipeline = $true)]$inputObject) {
  $inputObject | Format-List -Property *
}

function gmi ($inputObject) {
  Get-Member -InputObject $inputObject
}

function galp ($pattern) {
  Get-Alias | Where-Object { $_.DisplayName -match $pattern }
}

function sbpf ($commandFileName) {
  Set-PSBreakpoint -Script (Get-Command $commandFileName).Source -Line 1
}

function cbp {
  Get-PSBreakpoint | Remove-PSBreakpoint
}

function dotrepo { Set-Location "C:\Users\andlam\Source\Repos\dotfiles" }

function erc {
  gvim "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
}

function ewrc {
  gvim "$env:USERPROFILE\Documents\WindowsPowerShell\WorkSpecific\Work_Powershell_Profile.ps1"
}

function rc {
  . "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
}

function Backup-DotFiles () {
    Run-DotfileBackup $env:USERPROFILE "$env:USERPROFILE\Source\Repos\dotfiles" "$env:USERPROFILE\Source\Repos\DES.Developer.Andlam"
}

function Import-DotFiles ($importMode = $false) {
    & "$env:USERPROFILE\Source\Repos\dotfiles\import.ps1" $env:USERPROFILE "$env:USERPROFILE\Source\Repos\dotfiles" $importMode
}
function Import-Work-DotFiles ($importMode = $false) {
    & "$env:USERPROFILE\Source\Repos\dotfiles\import-external.ps1" $env:USERPROFILE "$env:USERPROFILE\Source\Repos\dotfiles" "$env:USERPROFILE\Source\Repos\DES.Developer.Andlam" $importMode
}

### Helper Functions [HLPR] ###

# Coding [CDNG]

function ca ($mode) {
    Set-CodeAnalysisMode (Read-AnswerToBool $mode)
}

function fmtjson_clip {
  Get-Clipboard | ConvertFrom-Json | ConvertTo-Json | Set-Clipboard
}

function gbctp ($branchName, $commitMessage) {
  git checkout -b $branchName
  git add .
  git commit -m $commitMessage
  git push origin
  git checkout master
}

function gctp ($commitMessage) {
  git add .
  git commit -m $commitMessage
  git push origin
}

function gitBranchCleanup() {
    $branches = ($(git branch) | Where-Object { -not $_.StartsWith("*") }).Trim()

    $allBranches = ($(git branch --all) | Where-Object { -not $_.StartsWith("*") -and  -not $_.StartsWith("HEAD") -and $_.StartsWith("  remotes/origin/") }).Trim().Replace("remotes/origin/", "")
    # Might get expensive in future if lots of branch
    $delete = $branches | Where-Object { $allBranches -notcontains $_ }
    
    Write-Host "Branches to delete"
    $delete | ForEach-Object { Write-Host $_ }

    #TODO refactor into method
    $resp = Read-Host "Proceed?"
    if ($resp -cin @("t", "true", "y", "yes"))
    {
        $delete | ForEach-Object { git branch -D $_ }
    }
}



# Import work specific code
if (Test-Path "$env:USERPROFILE\Documents\WindowsPowerShell\WorkSpecific\Work_Powershell_Profile.ps1") {
    . "$env:USERPROFILE\Documents\WindowsPowerShell\WorkSpecific\Work_Powershell_Profile.ps1"
}