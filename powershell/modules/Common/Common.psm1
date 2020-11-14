
Set-StrictMode -Version Latest

function Start-ProcessWithRedirect {
    param (
        $FilePath,
        $ArgumentList
    )
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo.FileName = $FilePath
    #$p.StartInfo.RedirectStandardError = $true
    $p.StartInfo.RedirectStandardOutput = $true
    $p.StartInfo.UseShellExecute = $false
    $p.StartInfo.Arguments = $ArgumentList
    $p.StartInfo.WindowStyle = "Hidden"
    $p.Start() > $null
    # TODO, redirect to memorystream rather than single read for deadlock resistance with both stdout + stderr
    $stdout =  $p.StandardOutput.ReadToEnd()
    # Maybe can also deadlock if stderr fills up while trying to read stdout?
    #    stderr = $p.StandardError.ReadToEnd()

    # Can deadlock if wait happens before reading all of redirected streams
    # child writes to stream and blocks because it is full.
    $p.WaitForExit()
    [PSCustomObject]@{
        command = $FilePath + $ArgumentList
        stdout = $stdout
        #stderr = $stderr
        ExitCode = $p.ExitCode
    }
}

# Windows Commands
function Start-CommandTxtAsAdmin {
    param (
        $commandTxt
    )
    
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Start-Process powershell -Verb runAs -ArgumentList $commandTxt -Wait
    }
}

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

function Get-MachineIpAddress {
    (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPV4" -and $_.InterfaceAlias -match "\(Ethernet\)"}).IPAddress
}


# Text Manipulation

function Read-AnswerToBool {
    param(
        [string] $userAnswerText
    )
    $userAnswerText -cin @("yes", "y", "t", "true", "on")
}

function Get-EscapedRegex {
    param (
        [string] $stringForRegex
    )
    [System.Text.RegularExpressions.Regex]::Escape($stringForRegex)
}

function Get-WindowsPath {
    param (
        $path
    )
    $path -replace "/","\"
}

################################################################################
# User Interaction Helpers
#
# These function prompt user for data with retry logic.
################################################################################

function Read-UserChoiceFromArray {
    param(
        $choices,
        [ScriptBlock] $choiceSelectFn
    )

    Write-Host "Select an entry:"
    $i = 1
    foreach ($choice in $choices) {
        if ($choiceSelectFn) {
            $choiceDisplayText = & $choiceSelectFn $choice
            Write-Host "[$i] $choiceDisplayText"
        } else {
            Write-Host "[$i] - $choice"
        }
        $i++
    }
    $choiceIndex = [int] (Read-Host -Prompt "Enter choice> ")
    $choices[$choiceIndex - 1];
}

function Get-RunningVM {
    while ($true) {
        $vm = Get-VM | Where-Object { $_.State -eq "Running" } | Select-Object -First 1
        if ($vm) {
            break
        }
        Write-Error "Failed to locate running VM"
        Read-Host -Prompt "press enter to find VM..." > $null
    }
    $vm
}

# Takes a range list e.g. "1-3,4,6" and enumerates the range into the
# pipeline. For that input, output is 1,2,3,4,6
function Get-RangeList {
    param (
        [string] $userIndicies
    )
    foreach ($userRange in $userIndicies -split ",") {
        if ($userRange -match "\-") {
            $rangeParams = $userRange -split "\-"
            $rangeParams[0]..$rangeParams[1]
        } else {
            $userRange
        }
    }
}

# Takes an array and the output of Get-RangeList and filters
# The array to the given elements
function Get-FilterArray {
    param (
        $array,
        $indicesToKeep
    )
    $indicesToKeepMap = @{}
    foreach ($index in $indicesToKeep) {
        $indicesToKeepMap["$index"] = $true
    }
    $i = 0;
    foreach ($element in $array) {
        if ($indicesToKeepMap["$i"]) {
            $array[$i]
        }
        $i++
    }
}

function Get-PlaintextFromSecureString {
    param (
        [SecureString] $password
    )

    $unmanagedPlaintextString = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($unmanagedPlaintextString) # emits output
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($unmanagedPlaintextString) 
}

function Get-CredentialObjectForCurrentUser {
    param (
        [SecureString] $Password
    )

    New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList @($(whoami.exe), $Password)
}

function Get-CredentialObjectForCreds {
    param (
        $parts # ["username", "password"]
    )
      
    $secpwd = ConvertTo-SecureString $parts[1] -AsPlainText -Force
    New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $parts[0], $secpwd
}

# Shortcuts for invoke-command
function Invoke-OnVM {
    # Adding Cmdlet to support erroraction. Invoke-Command sometimes throws non-terminating errors so
    # this function must support ErrorAction=Stop to enable catching those.
    [CmdletBinding()]
    param (
        $vmName,
        [PSCredential]$cred,
        $cmd,
        $argList = $null
    )
    if ($argList) {
        Invoke-Command -VMName $vmName -Credential $cred -ScriptBlock $cmd -ArgumentList $argList
    } else {
        Invoke-Command -VMName $vmName -Credential $cred -ScriptBlock $cmd
    }
}

function Invoke-OnVMAsJob {
    [CmdletBinding()]
    param (
        $vmName,
        [PSCredential]$cred,
        $cmd,
        $arglist = $null
    )
    if ($arglist) {
        Invoke-Command -VMName $vmName -Credential $cred -ScriptBlock $cmd -ArgumentList $arglist -AsJob
    } else {
        Invoke-Command -VMName $vmName -Credential $cred -ScriptBlock $cmd -AsJob
    }
}






# Coding and build

function Set-CodeAnalysisMode {
    param (
        [bool] $mode
    )
    $caFile = Get-Content -Raw ".\build.props"
    $newCaFile = $caFile -replace "<RunCodeAnalysis>\w*</RunCodeAnalysis>", "<RunCodeAnalysis>$mode</RunCodeAnalysis>"
    Set-Content -Path ".\build.props" -Value $newCaFile -Force
}

# Reads Ini file into Double-nested Hash
# Taken From https://blogs.technet.microsoft.com/heyscriptingguy/2011/08/20/use-powershell-to-work-with-any-ini-file/
function Get-IniContent($filePath)
{
    $ini = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
        }
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

function Start-Watch($from, $to, $debugLogFile = $null) {
    Start-Job -ScriptBlock {
        param ($from, $to, $debugLogFile)
        function LogString($string) {
            if ($debugLogFile) {
                Add-Content $debugLogFile "$((get-date).ToString("hh:mm:ss")) [Watch] - $string"
            }
        }
        function HandleChange($eventArgs) {
            $name = $eventArgs.Name
            $src = [System.IO.Path]::Combine($from, $name)
            $dest = [System.IO.Path]::Combine($to, $name)
            $srcItem = Get-Item $src
            if ($srcItem.PSIsContainer) {
                if (-not (Test-Path $dest)) {
                    New-Item $dest -ItemType Directory
                    LogString "[$($eventArgs.ChangeType)] CopyDirectory  $src to $dest"
                }
            } else {
                Copy-Item $src -Destination $dest -Force
                LogString "[$($eventArgs.ChangeType)] Copy $src to $dest"
            }
        }
        function HandleDeleted($eventArgs) {
            $name = $eventArgs.Name
            $dest = [System.IO.Path]::Combine($to, $name)
            Remove-Item $dest -Force -Recurse
            LogString "Deleted $dest"
        }
        function HandleRename($eventArgs) {
            $oldName = [System.IO.Path]::Combine($to, $eventArgs.OldName)
            $newName = [System.IO.Path]::Combine($to, $eventArgs.Name)
            Move-Item -Path $oldName -Destination $newName -Force
            LogString "Rename $oldName to $newName"
        }
        try {
            LogString "Create Watcher from $from to $to"

            $watcher = New-Object System.IO.FileSystemWatcher -Property @{
                Path = $from;
                IncludeSubdirectories = $true
            }
            
            $watcherId = (New-Guid).ToString()
            Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier "$watcherId`_Created" -Action { HandleChange $event.SourceEventArgs }
            Register-ObjectEvent -InputObject $watcher -EventName Deleted -SourceIdentifier "$watcherId`_Deleted" -Action { HandleDeleted $event.SourceEventArgs }
            Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier "$watcherId`_Changed" -Action { HandleChange $event.SourceEventArgs }
            Register-ObjectEvent -InputObject $watcher -EventName Renamed -SourceIdentifier "$watcherId`_Renamed" -Action { HandleRename $event.SourceEventArgs }

            $watcher.EnableRaisingEvents = $true

            while ($true) {
                Start-Sleep -Seconds 1
            }
        } finally {
            if ($watcher) {
                $watcher.EnableRaisingEvents = $false
                Unregister-Event -SourceIdentifier "$watcherId`_Created"
                Unregister-Event -SourceIdentifier "$watcherId`_Deleted"
                Unregister-Event -SourceIdentifier "$watcherId`_Changed"
                Unregister-Event -SourceIdentifier "$watcherId`_Renamed"
            }
            LogString "Unregister events for from $from to $to"
        }
    } -ArgumentList $from, $to, $debugLogFile
}
