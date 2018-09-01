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
    Write-Host "[$mode] $from --> $to"
    if ($mode -ceq "Directory") {
        Copy-Item -Recurse -Force -Path ((EnsureTrailingSlash $from) + "*") -Destination $to
    } else {
        Copy-Item -Force -Path $from -Destination $to
    }
}
function ProcessMapping ($repoDir, $homeDir, $mapping, $importMode) {
    $sourceFullPath = $repoDir + (NormalizeToWindowsPath $mapping.Source)
    $destinationFullPath = $homeDir + (NormalizeToWindowsPath $mapping.Destination)
    
    if ($importMode) {
        MoveFile $sourceFullPath $destinationFullPath $mapping.Mode
    } else {
        MoveFile $destinationFullPath $sourceFullPath $mapping.Mode
    }
}
