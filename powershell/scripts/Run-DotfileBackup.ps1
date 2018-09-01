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
    [string] $externalRepoDir
)

$commitMessage = "User-initiated dotfile backup $((Get-Date).ToUniversalTime())"

function CommitAndPush($dir) {
    Set-Location $dir
    git checkout master
    git add .
    git commit -m $commitMessage
    git push origin master
}

Write-Host "Backing up dotfiles"
& "$dotFilesRepoDir\import.ps1" $homeDir "$dotFilesRepoDir" $false
& "$dotFilesRepoDir\import-external.ps1" $homeDir "$dotFilesRepoDir" "$externalRepoDir" $false

Write-Host "Commiting and pushing changes"
CommitAndPush $dotFilesRepoDir
CommitAndPush $externalRepoDir
