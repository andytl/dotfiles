<#
.DESCRIPTION
Copies files from a VM using only powershell remoting. No network access is needed.
#>
function Copy-FromVM {
    [CmdletBinding()]
    param (
        # The target VM.
        [Parameter(Mandatory)]
        [string] $VMName,
        # The credential of the account to use on the target VM.
        [Parameter(Mandatory)]
        [PSCredential] $VMCred,
        # Glob specifying the files to copy from the VM
        [Parameter(Mandatory)]
        [string] $Source,
        # Directory on the host which receives the files
        [Parameter(Mandatory)]
        [string] $DestinationDir

    )
    if (Test-Path -PathType Leaf -Path $DestinationDir) {
        throw "DestinationDir cannot be a file"
    }
    New-Item -ItemType Directory -ErrorAction Ignore -Path $DestinationDir > $null

    Invoke-Command -VMName $VMName `
        -Credential $VMCred `
        -ErrorAction Stop `
        -ArgumentList $Source `
        -ScriptBlock {
            param ([string] $Source)
            $isDirectory = Test-Path -PathType Container -Path $Source
            Get-ChildItem -File -Path $Source | & { process { 
                if ($isDirectory) {
                    $relPath = [System.IO.Path]::GetRelativePath($Source,$_.FullName)
                } else {
                    $relPath = $_.Name
                }
                [PSCustomObject] @{
                    FileBytes = [System.IO.File]::ReadAllBytes($_.FullName);
                    Path = $relPath
                }
            }}
        } | & { process {
            $parent = Split-Path $_.Path -Parent
            if ($parent) {
                $dir = Join-Path $DestinationDir $parent
                Write-Verbose "Create $dir"
                New-Item -ItemType Directory -ErrorAction Ignore -Path $dir > $null
            }
            $file = Join-Path $DestinationDir $_.Path
            [System.IO.File]::WriteAllBytes($file, $_.FileBytes)
            $file
        }}
}