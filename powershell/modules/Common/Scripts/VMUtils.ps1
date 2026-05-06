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


<#
.SYNOPSIS
Prepare a file or directory to copy to VM.

.DESCRIPTION
Reads the file into memory, returns object containing the file.
Currently does not recurse for directory.

.PARAMETER entry
{
    source: "c:\path_to_file\file.ext", # Local filesystem path (file or directory)
    destination: "c:\path_to_destination\" # directory
}

.OUTPUTS
[
    {
        name: "file.ext"
        path: "c:\path_to_file\file.ext", # Absolute filesystem path
        data: byte[] # File content bytes
    },
    ...
]
#>
function Format-FilesForVM {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        $entry
    )

    process {
        $item = Get-Item $entry.source
        if ($item.PSIsContainer) {
            (Get-ChildItem -File $item).ForEach{
                $name = $_.Name
                [PSCustomObject]@{
                    name = $name;
                    path = Join-Path $entry.destination $name;
                    data = [System.IO.File]::ReadAllBytes($_.FullName)
                }
            }
        } else {
            $name = $item.Name
            [PSCustomObject]@{
                name = $name;
                path = Join-Path $entry.destination $name;
                data = [System.IO.File]::ReadAllBytes($item.FullName)
            }
        }
    }
}

<#
Receiver counterpart to Prepare-FilesForVM
Writes the files specified to the filesystem, intended to run on the VM.
Creates a backup before replacing.

Output:
[
    {
        path = $_.path;
        success = $true;
        output = $null;
    }
]
#>
function Receive-FilesOnVM {
    [CmdletBinding()]
    param (
        <#
        The files that should be copied to the VM.
        [
            {
                name: "file.ext",
                path: "c:\path_to_file\file.ext", # Absolute filesystem path
                data: byte[]
            },
            ... < repeat > ...
        ]
        #>
        $FilesToDrop
    )

    $FilesToDrop.ForEach{
        <# $_ has: name, path, data #>
        $backupPath = "$($_.path).old"
        if (-not (Test-Path $backupPath) -and (Test-Path $_.path)) {
            Copy-Item -Path $_.path -Destination $backupPath
        }
        $result = [PSCustomObject]@{
            path = $_.path;
            success = $true;
            output = $null;
        }
        $result.output = try {
            New-Item -Path (Split-Path -Parent $_.path) -ItemType Directory -ErrorAction SilentlyContinue
            [System.IO.File]::WriteAllBytes($_.path, $_.data)
        } catch {
            $result.success = $false
            [string] $_.Exception
        }

        $result
    }
}