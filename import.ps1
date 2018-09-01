[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true,Position=1)]
    [string] $homeDir,
    [Parameter(Mandatory=$true,Position=2)]
    [string] $repoDir,
    # true = Copy (import) into home dir, false = copy into repo
    [Parameter(Mandatory=$false,Position=3)]
    [switch] $importMode = $false
)

Set-StrictMode -Version Latest

function EnsureTrailingSlash($path) {
    if ($path.EndsWith("\")) {
        $path
    } else {
        $path + "\"
    }
}

function NormalizeToWindowsPath ($path) {
    $path.Replace("/", "\")
}

function MoveFile ($from, $to, $mode) {
    if ($mode -ceq "Directory") {
        #echo "Copy-Item -Recurse -Force -Path $from -Destination $to"
        Copy-Item -Recurse -Force -Path $from -Destination $to
    } else {
        #echo "Copy-Item -Force -Path $from -Destination $to"
        Copy-Item -Force -Path $from -Destination $to
    }
}
function ProcessMapping ($mapping) {
    $sourceFullPath = $repoDir + (NormalizeToWindowsPath $mapping.Source)
    $destinationFullPath = $homeDir + (NormalizeToWindowsPath $mapping.Destination)
    
    if ($importMode) {
        MoveFile $sourceFullPath $destinationFullPath $mapping.Mode
    } else {
        MoveFile $destinationFullPath $sourceFullPath $mapping.Mode
    }
}

$homeDir = EnsureTrailingSlash $homeDir
$repoDir = EnsureTrailingSlash $repoDir

$windowsMapping = Get-Content -Raw "$repoDir\mappings_windows.json" | ConvertFrom-Json
$commonMapping = Get-Content -Raw "$repoDir\mappings_common.json" | ConvertFrom-Json

$windowsMapping | ForEach-Object { ProcessMapping $_ }
$commonMapping | ForEach-Object { ProcessMapping $_ }