<#
Get the initial dependencies of the dotfiles repo before we begin. Of course, this is only needed on windows because 
#>

$workingDir = "$env:USERPROFILE\Downloads\bootstrap_windows"
New-Item -ItemType Directory -Path $workingDir -Force > $null
Set-Location -Path $workingDir

$ErrorActionPreference = "Stop"

# Seems that some websites use newer versions and powershell defaults are not good enough.
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

function RefreshPath {
    $env:Path =
        [System.Environment]::GetEnvironmentVariable("Path","Machine") +
        ";" + 
        [System.Environment]::GetEnvironmentVariable("Path","User")
}

function GitHubGetLatestRelease {
    <#
    Release JSON is array of:
  {
    ....
    "tag_name": "v2.24.0.windows.2",
    ...
    "name": "Git for Windows 2.24.0(2)",
    ...
    "published_at": "2019-11-06T19:51:29Z",
    "assets": [
      {
        ...
        "name": "Git-2.24.0.2-64-bit.exe",
        ...
        "browser_download_url": "https://github.com/git-for-windows/git/releases/download/v2.24.0.windows.2/Git-2.24.0.2-64-bit.exe"
      },
      ...
    ],
    ...
  }
    #>
    param (
        $project,
        $nameRegex,
        $assetRegex
    )

    $releasesList = Invoke-RestMethod -Method Get "https://api.github.com/repos/$project/releases"
    $release = $releasesList | Sort-Object -Property published_at -Descending | Where-Object { $_.name -match $nameRegex } | Select-Object -First 1
    $releaseExeAsset = $release.assets | Where-Object { $_.name -match "$assetRegex" }
    if (-not $releaseExeAsset) {
        $release.assets | ForEach-Object { Write-Object "$($_.name) -> $($_.browser_download_url)" }
        throw "No release matching asset for `"$assetRegex`" found"
    }
    return @{
        Url = $releaseExeAsset.browser_download_url;
        Name = $releaseExeAsset.name
    }
}

function WaitForAllOf {
    param (
        $processGlob
    )
    $processes = $null
    while (-not $processes) {
        $processes = (Get-Process "*$processGlob*")
    }
    foreach ($process in $processes) { 
        $process.WaitForExit()
    }
}

function TryDownload {
    param (
        $url,
        $output
    )
    if (-not (Test-Path $output)) {
        Invoke-WebRequest $url -OutFile $output
    }
}

# Get Git for windows
function GetGitForWindows {
    Write-Output "GetGitForWindows"
    $inf = @"
[Setup]
Lang=default
Dir=C:\Program Files\Git
Group=Git
NoIcons=0
SetupType=default
Components=ext,ext\shellhere,ext\guihere,gitlfs,assoc,assoc_sh
Tasks=
EditorOption=VIM
CustomEditorPath=
PathOption=Cmd
SSHOption=OpenSSH
CURLOption=WinSSL
CRLFOption=CRLFCommitAsIs
BashTerminalOption=ConHost
PerformanceTweaksFSCache=Enabled
UseCredentialManager=Enabled
EnableSymlinks=Disabled
"@
    $inf | Out-File -FilePath ".\git_settings.inf" -Encoding utf8 -Force
    $release = GitHubGetLatestRelease "git/git-for-windows" "Git For Windows" "Git-.*-64-bit\.exe"
    $releaseExePath = ".\$($release.Name)"
    TryDownload $release.Url $releaseExePath

    & $releaseExePath "/LOG=`".\git_install.log`"" /SILENT /NORESTART /CLOSEAPPLICATIONS "/SP-" /SUPPRESSMSGBOXES /LOADINF=".\git_settings.inf"
    # MSIExec returns immediately so need to wait
    WaitForAllOf "git"
    $result = Get-Content -Path .\git_install.log
    if (-not ($result | Where-Object { $_ -match "Installation process succeeded."})) {
        Write-Error "Failed to install git, see git_install.log"
        throw "install failed."
    }

    # Install POSH-GIT
    Write-Output "Install POSH-GIT"
    Install-PackageProvider -Name Nuget -Force > $null
    Install-Module posh-git -Scope AllUsers -Force > $null
}

function GetPython {
    Write-Output "GetPython"
    #TODO autodetect version
    $ver = "3.7.2"
    $exeUrl = "https://www.python.org/ftp/python/$ver/"
    $exeName = "python-$ver-amd64.exe"
    $exePath = ".\$exeName"
    TryDownload $exeUrl $exePath

    & $exePath /passive /log "python_install.log" InstallAllUsers=1 PrependPath=1 CompileAll=1 # MSIExec returns immediately so need to wait
    WaitForAllOf "python"
    $result = Get-Content -Path .\python_install.log
    if (-not ($result | Where-Object { $_ -match "Exit code: 0x0"})) {
        Write-Error "Failed to install python, see python_install.log"
    }
}

function GetFirefox {
    Write-Output "GetFirefox"
    $inf = @"
[Install]
QuickLaunchShortcut=false
TaskbarShortcut=false
DesktopShortcut=false
"@
    $inf | Out-File -FilePath ".\firefox_settings.ini" -Encoding utf8 -Force
    TryDownload "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US" "firefox_install.exe"
    .\firefox_install.exe "/INI=$workingDir\firefox_settings.ini" /S
    WaitForAllOf "setup"
}

function GetDotfileRepo {
    Write-Output "GetDotfileRepo"
    New-Item -ItemType Directory -Path "$env:USERPROFILE\Source\Repos" -Force > $null
    #ssh-keygen.exe -q -f "$env:USERPROFILE\.ssh\id_rsa" -t rsa -N '""'
    $repoDir = "$env:USERPROFILE\Source\Repos\dotfiles"
    #(ssh-keyscan github.com) | Out-File  ~\.ssh\known_hosts -Append
    git clone "https://github.com/andytl/dotfiles.git" $repoDir
    python "$repoDir\import.py" $env:USERPROFILE $repoDir import
}

function GetAutoHotKey {
    Write-Output "GetAutoHotKey"
    TryDownload "https://www.autohotkey.com/download/ahk-install.exe" ".\ahk-install.exe"
    .\ahk-install.exe /S
    WaitForAllOf "ahk-install"
}

function GetConEmu {
    Write-Output "GetConEmu"
    $release = GitHubGetLatestRelease "Maximus5/ConEmu" "\d+" "ConEmuSetup.*.exe"
    $releaseExePath = ".\$($release.Name)"
    TryDownload $release.Url $releaseExePath

    & $releaseExePath "/p:x64,adm" /passive
    # MSIExec returns immediately so need to wait
    WaitForAllOf "conemusetup"
}

function GetVSCode {
    $infPath = ".\vscode_settings.inf"
    $inf = @"
[Setup]
Lang=english
Dir=C:\Program Files\Microsoft VS Code
Group=Visual Studio Code
NoIcons=0
Tasks=addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath
"@
    $inf | Out-File -FilePath $infPath -Encoding utf8 -Force

    Write-Output "GetVSCode"
    $exePath = ".\VSCodeSetup-x64.exe"
    TryDownload "https://go.microsoft.com/fwlink/?Linkid=852157" $exePath

    $logPath = ".\vscode_install.log"
    # VSCode uses INNO Setup
    & $exePath /SILENT /NORESTART /CLOSEAPPLICATIONS /LOADINF="$infPath" /LOG="$logPath"
    WaitForAllOf "VSCodeSetup"
    
    $result = Get-Content -Path $logPath
    if (-not ($result | Where-Object { $_ -match "Installation process succeeded."})) {
        Write-Error "Failed to install vscode, see $logPath"
    }

    # Install extensions
    RefreshPath
    code --install-extension ms-vscode.powershell
    code --install-extension ms-vscode.cpptools
    code --install-extension streetsidesoftware.code-spell-checker
    #code --install-extension 
}

function GetNotepadPlusPlus { # TODO: Unhardcode version
    Write-Output "GetNotepadPlusPlus"
    $exePath = ".\npp.installer.exe"
    TryDownload "http://download.notepad-plus-plus.org/repository/7.x/7.8.1/npp.7.8.1.Installer.x64.exe" $exePath

    & $exePath /S
    # MSIExec returns immediately so need to wait
    WaitForAllOf "npp"
}

function Get7z {
    Write-Output "Get7z"
    $exePath = ".\7zx64.installer.exe"
    TryDownload "https://www.7-zip.org/a/7z1900-x64.exe" $exePath

    & $exePath /S
    # MSIExec returns immediately so need to wait
    WaitForAllOf "7zx64.installer"
}


if (-not (Test-Path "C:\Program Files\*Firefox*")) {
    GetFirefox
}
if (-not (Test-Path "C:\Program Files\*Git*")) {
    GetGitForWindows
}
if (-not (Test-Path "C:\Program Files\*Python*")) {
    GetPython
}
if (-not (Test-Path "C:\Program Files\*AutoHotkey*")) {
    GetAutoHotKey
}
if (-not (Test-Path "C:\Program Files\*ConEmu*")) {
    GetConEmu
}
if (-not (Test-Path "C:\Program Files\Microsoft VS Code")) {
    GetVSCode
}
if (-not (Test-Path "C:\Program Files\Notepad++")) {
    GetNotepadPlusPlus
}




if (-not (Test-Path "$env:USERPROFILE\Source\Repos\dotfiles")) {
    RefreshPath
    GetDotfileRepo
}

Write-Output "Reboot the shell to continue...."
