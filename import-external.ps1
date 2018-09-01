<#
This script will perform the same dotfile backup but to a different repository for code that
should not be in this repository.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1)]
    [string] $homeDir,
    [Parameter(Mandatory=$true,Position=2)]
    [string] $dotFilesRepoDir,
    [Parameter(Mandatory=$true,Position=3)]
    [string] $externalRepoDir,
    # true = Copy (import) into home dir, false = copy into repo
    [Parameter(Mandatory=$false,Position=4)]
    [switch] $importMode = $false
)

Set-StrictMode -Version Latest

. "$dotFilesRepoDir\import-common.ps1"

$homeDir = EnsureTrailingSlash $homeDir
$externalRepoDir = EnsureTrailingSlash $externalRepoDir

$mapping = Get-Content -Raw "$externalRepoDir\mappings.json" | ConvertFrom-Json

$mapping | ForEach-Object { ProcessMapping $externalRepoDir $homeDir $_ $importMode }