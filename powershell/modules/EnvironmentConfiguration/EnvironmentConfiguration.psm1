
Set-StrictMode -Version Latest

function Set-EnvironmentVariable {
    param (
        [string] $variableName,
        [string] $variableValue
    )
    [System.Environment]::SetEnvironmentVariable(
        $variableName,
        $variableValue,
        [System.EnvironmentVariableTarget]::User
    )
}

function Clear-EnvironmentVariable {
    param (
        [string] $variableName
    )
    [System.Environment]::SetEnvironmentVariable(
        $variableName,
        $null,
        [System.EnvironmentVariableTarget]::User
    )
}

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
    if (Test-Path $directory) {
        foreach ($subDir in (Get-ChildItem -Path $directory -Directory)) {
            Add-PathIfPresent $subDir.FullName
        }
    }
}

# Setters for Specific env Vars
function Set-EnvironmentSslKeyLogFile ($enabled) {
  # Enable Secret logging for TLS connections
  # https://jimshaver.net/2015/02/11/decrypting-tls-browser-traffic-with-wireshark-the-easy-way/
  $varName = "SSLKEYLOGFILE"
  $varValue = "$env:USERPROFILE\Documents\sslkeylog.log"
  if ($enabled) {
    Set-EnvironmentVariable $varName $varValue
  } else {
    Clear-EnvironmentVariable $varName
  }
}
