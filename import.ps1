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

. "$repoDir\import-common.ps1"

$homeDir = EnsureTrailingSlash $homeDir
$repoDir = EnsureTrailingSlash $repoDir

$windowsMapping = Get-Content -Raw "$repoDir\mappings_windows.json" | ConvertFrom-Json
$commonMapping = Get-Content -Raw "$repoDir\mappings_common.json" | ConvertFrom-Json

$windowsMapping | ForEach-Object { ProcessMapping $repoDir $homeDir $_ $importMode }
$commonMapping | ForEach-Object { ProcessMapping $repoDir $homeDir $_ $importMode }