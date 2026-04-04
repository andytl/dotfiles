Set-StrictMode -Version Latest

$UserPSModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
if (-not $env:PSModulePath.Contains($UserPSModulePath)) {
  $env:PSModulePath += ";$UserPSModulePath"
}

Import-Module PSReadLine
Import-Module posh-git -ErrorAction SilentlyContinue
Import-Module oh-my-posh -ErrorAction SilentlyContinue

# Setup PSReadLine
Set-PSReadlineKeyHandler -Key Tab -Function Complete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Chord Ctrl+d -Function DeleteCharOrExit

Import-Module "Personal\Common" -Force 
Import-Module "Personal\EnvironmentConfiguration" -Force
Import-Module "Personal\GitHelpers" -Force

Add-PathIfPresent "$env:USERPROFILE\Documents\WindowsPowerShell\Scripts"
Add-PathIfPresent "$env:USERPROFILE\bin"
Add-SubdirectoryPathIfPresent "$env:USERPROFILE\bin"
Add-PathIfPresent "$env:USERPROFILE\scripts\personal\python"

# Import work specific code for work machines.
if (Test-Path "$env:USERPROFILE\Documents\WindowsPowerShell\WorkSpecific\profile.ps1") {
  . "$env:USERPROFILE\Documents\WindowsPowerShell\WorkSpecific\profile.ps1"
}

# Setup Profile related items and aliases 
# Remove this alias, want to use the real deal.
if (Test-Path alias:curl) {
  Remove-Item alias:curl
}
Set-Alias g git
Set-Alias cjson ConvertTo-Json
Set-Alias gclip Get-Clipboard

function Backup-DotFiles () {
  python "$env:USERPROFILE\Source\Repos\dotfiles\import.py" $env:USERPROFILE "$env:USERPROFILE\Source\Repos\dotfiles" backup
}

function Import-DotFiles ($importMode) {
  python "$env:USERPROFILE\Source\Repos\dotfiles\import.py" $env:USERPROFILE "$env:USERPROFILE\Source\Repos\dotfiles" import
}

function Get-UserCommands {
  param (
    [string] $pattern = ""
  )
  $commands = @(
      Get-Command -CommandType ExternalScript *$pattern*  | Where-Object { $_.Source.StartsWith($env:USERPROFILE) }
      # User commands don't have source or helpfile arguments
      Get-Command -CommandType Function *$pattern* | Where-Object { (-not $_.Source -or $_.Version -eq "0.0") -and -not $_.HelpFile }
  )
  
  $limit = 200
  $commands | ForEach-Object {
    $description = $_.Definition.Trim() -replace "`n"," \n "
    if ($description.Length -gt $limit)
    {
        $description = $description.SubString(0, $limit)
    }
    [PSCustomObject]@{
    CommandType = $_.CommandType;
    Name = $_.Name;
    Source = $_.Source;
    Description = $description;
    }
  }
}

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

function dotrepo { Set-Location "$env:USERPROFILE\Source\Repos\dotfiles" }

function rc {
  . "$env:USERPROFILE\Documents\WindowsPowerShell\profile.ps1"
}

function cdl {
  $f = Get-ChildItem .\ | Sort-Object -Property CreationTime -Descending | Select-Object -First 1
  Set-Location $f
}

### Helper Functions [HLPR] ###

# Coding [CDNG]

function fmtjson_clip {
  Get-Clipboard | ConvertFrom-Json | ConvertTo-Json | Set-Clipboard
}

function code-admin {
  # https://github.com/microsoft/vscode/issues/184888
  code --no-sandbox --disable-gpu-sandbox
}

function codecpp() {
  $paths = @(
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat",
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\VsDevCmd.bat"
  )
  foreach ($path in $paths) {
    if (Test-Path -Path $path) {
      cmd /k "`"$path`" && code && exit"
      return;
    }
  }
  Write-Host "Could not find VsDevCmd.bat"
}

function VsDevShell {
  & 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\Launch-VsDevShell.ps1'
}
