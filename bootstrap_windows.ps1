<#
Get the initial dependencies of the dotfiles repo before we begin. Of course, this is only needed on windows because 
#>

$workingDir = "$env:USERPROFILE\Downloads\bootstrap_windows"
New-Item -ItemType Directory -Path $workingDir -Force > $null
Set-Location -Path $workingDir

$ErrorActionPreference = "Stop"
function RefreshPath {
    $env:Path =
        [System.Environment]::GetEnvironmentVariable("Path","Machine") +
        ";" + 
        [System.Environment]::GetEnvironmentVariable("Path","User")
}

function WaitForAllOf {
    param (
        $processGlob
    )
    Start-Sleep -Milliseconds 500
    foreach ($process in (Get-Process "*$processGlob*")) { 
        $process.WaitForExit()
    }
}

# Get Git for windows
function GetGitForWindows {
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
    Write-Output "GetGitForWindows"
    Out-File -FilePath ".\git_settings.inf" -Encoding utf8 -Force
    $releasesList = Invoke-RestMethod "https://api.github.com/repos/git-for-windows/git/releases"
    $release = $releasesList | Sort-Object -Property published_at -Descending | Where-Object { $_.name -match "Git For Windows" } | Select-Object -First 1
    $releaseExeAsset = $release.assets | Where-Object { $_.name -match "Git-.*-64-bit.exe" }
    $releaseExeUrl = $releaseExeAsset.browser_download_url
    $releaseExePath = ".\$($releaseExeAsset.name)"
    if (-not (Test-Path $releaseExePath)) {
        Invoke-WebRequest $releaseExeUrl -OutFile $releaseExePath
    }
    & $releaseExePath "/LOG=`".\git_install.log`"" /SILENT /NORESTART /CLOSEAPPLICATIONS "/SP-" /SUPPRESSMSGBOXES /LOADINF=".\git_settings.inf"
    # MSIExec returns immediately so need to wait
    WaitForAllOf "git"
    $result = Get-Content -Path .\git_install.log
    if (-not ($result | Where-Object { $_ -match "Installation process succeeded."})) {
        Write-Error "Failed to install git, see git_install.log"
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
    if (-not (Test-Path $exePath)) {
        Invoke-WebRequest "$exeUrl/$exeName" -OutFile $exePath
    }
    & $exePath /passive /log "python_install.log" InstallAllUsers=1 PrependPath=1 CompileAll=1# MSIExec returns immediately so need to wait
    WaitForAllOf "python"
    $result = Get-Content -Path .\python_install.log
    if (-not ($result | Where-Object { $_ -match "Exit code: 0x0"})) {
        Write-Error "Failed to install python, see python_install.log"
    }
}

function GetFirefox {
    Invoke-WebRequest "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US" -OutFile firefox_install.exe
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

#GetGitForWindows
GetPython
RefreshPath
GetDotfileRepo

Write-Output "Reboot the shell to continue...."
