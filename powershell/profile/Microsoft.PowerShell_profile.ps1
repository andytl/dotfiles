# Hello world (Dotfile backup test)

# Table of Contents
# Helper Functions [HLPR]
# VSTS Functions [VSTSF]
## Cosmos [CSMS]
## Coding [CDNG]

Set-StrictMode -Version Latest

# Imports=
Import-Module "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\posh-git\0.7.1\posh-git.psm1" # posh-git
Import-Module PSReadLine

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

function regexEscape ($stringForRegex) {
    [System.Text.RegularExpressions.Regex]::Escape($stringForRegex)
}

function formatTime ($time) {
    $time.ToString("h:mm tt")
}
function formatTimeSpan ($timespan, $seconds = $false) {
    $fmt = "m\m"
    if ($timespan.Hours -gt 0 -or $timespan.Days -gt 0) {
        $fmt = "h\h\ " + $fmt
    }
    if ($timespan.Days -gt 0) {
        $fmt = "d\d\ " + $fmt
    }
    if ($seconds) {
        $fmt = $fmt + "\ s\s"
    }
    $timespan.ToString($fmt)
}

# Coding [CDNG]

function ca ($mode) {

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
    $branches = ($(git branch) | ? { -not $_.StartsWith("*") }).Trim()

    $allBranches = ($(git branch --all) | ? { -not $_.StartsWith("*") -and  -not $_.StartsWith("HEAD") -and $_.StartsWith("  remotes/origin/") }).Trim().Replace("remotes/origin/", "")
    # Might get expensive in future if lots of branch
    $delete = $branches | ? { $allBranches -notcontains $_ }
    
    Write-Host "Branches to delete"
    $delete | % { Write-Host $_ }

    #TODO refactor into method
    $resp = Read-Host "Proceed?"
    if ($resp -cin @("t", "true", "y", "yes"))
    {
        $delete | % { git branch -D $_ }
    }
}



# Import work specific code
if (Test-Path "$env:USERPROFILE\Documents\WindowsPowerShell\WorkSpecific\Work_Powershell_Profile.ps1") {
    . "$env:USERPROFILE\Documents\WindowsPowerShell\WorkSpecific\Work_Powershell_Profile.ps1"
}