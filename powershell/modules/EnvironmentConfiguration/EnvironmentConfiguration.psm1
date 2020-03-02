
Set-StrictMode -Version Latest

Import-Module "Personal\Common"

function Add-PSModulePath {
    param(
        [string] $modulePath
    )
    
    if (-not $env:PSModulePath.Contains($modulePath)) {
        $env:PSModulePath += ";$modulePath"
    }
}

function Add-PathIfPresent {
    param(
        [string] $binPath
    )
    
    if (-not ($env:PATH -match "(^|;)$(Get-EscapedRegex $binPath)($|;)") -and (Test-Path $binPath)) {
        $env:PATH += ";$binPath"
    }
}

function Add-SubdirectoryPathIfPresent {
    param (
        $directory
    )
    foreach ($subDir in (Get-ChildItem -Path $directory -Directory)) {
        Add-PathIfPresent $subDir.FullName
    }
}