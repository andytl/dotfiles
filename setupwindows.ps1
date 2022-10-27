
$ErrorActionPreference = "Stop"

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

function RefreshPath {
    $env:Path =
        [System.Environment]::GetEnvironmentVariable("Path","Machine") +
        ";" + 
        [System.Environment]::GetEnvironmentVariable("Path","User")
}

function CreateShortcut {
    param (
        $targetFile,
        $shortcutFile
    )
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutFile)
    $Shortcut.TargetPath = $targetFile
    $Shortcut.Save()
}


choco feature enable -n allowGlobalConfirmation

choco install 

choco install vcredist140
choco install microsoft-windows-terminal

choco install firefox

choco install notepadplusplus.install

choco install python

#choco install 7zip.install
# install 7z via installer so we get the context menu items
function Get7z {
    Write-Output "Get7z"
    $exePath = "$env:USERPROFILE\Downloads\7zx64.installer.exe"
    TryDownload "https://d3.7-zip.org/a/7z2107-x64.exe" $exePath

    & $exePath /S
    # MSIExec returns immediately so need to wait
    WaitForAllOf "7zx64.installer"
}
if (-not (Test-Path "C:\Program Files\7-Zip")) {
    Get7z
}

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

choco install vlc

choco install git.install

choco install vscode
# Install extensions
RefreshPath
code --install-extension ms-vscode.powershell
code --install-extension ms-vscode.cpptools
code --install-extension streetsidesoftware.code-spell-checker

if (-not (Get-Command vim)) {
    choco install vim
    git clone https://github.com/VundleVim/Vundle.vim.git $env:USERPROFILE\.vim\bundle\Vundle.vim
    # TODO Fork this repo and use own copy for security.
    #git clone https://github.com/sickill/vim-monokai.git $env:USERPROFILE\vimfiles\colors\monokai_repo
    #Copy-Item $env:USERPROFILE\vimfiles\colors\monokai_repo\colors\*  $env:USERPROFILE\vimfiles\colors\
}

choco install autohotkey
$ahkShortcutPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey.lnk"
if (-not (Test-Path $ahkShortcutPath)) {
    CreateShortcut 'C:\Program Files\AutoHotkey\AutoHotkey.exe' $ahkShortcutPath
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
if (-not (Test-Path "$env:USERPROFILE\Source\Repos\dotfiles")) {
    RefreshPath
    GetDotfileRepo
}

# Apply custom registry settings
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Search /v BingSearchEnabled /t REG_DWORD /d 0 /f  
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Search /v AllowSearchToUseLocation /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Search /v CortanaConsent /t REG_DWORD /d 0 /f

# Disable Aero Peek
REG ADD "HKCU\SOFTWARE\Microsoft\Windows\DWM" /V EnableAeroPeek /T REG_DWORD /D 0 /F


#Disable windows welcome experience after updates, and disable new/suggested
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-310094Enabled /t REG_DWORD /d 0 /f
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement\ScoobeSystemSettingEnabled 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338382Enabled 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-353699Enabled 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\DisableAutoplay 1
#show suggestions in settings
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338386Enabled 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-353695Enabled 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-353697Enabled 0
#show suggestions in start
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SubscribedContent-338381Enabled 0
#show recently opened items in start/quick access
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_TrackDocs 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme 0
#badges on taskbar buttons
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarBadges
#gamebar
HKCU\SOFTWARE\Microsoft\GameBar\UseNexusForGameBarEnabled 0
#gamemode
HKCU\SOFTWARE\Microsoft\GameBar\AutoGameModeEnabled 0
#search settings
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings\IsMSACloudSearchEnabled 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings\IsAADCloudSearchEnabled 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings\IsDeviceSearchHistoryEnabled 0
#let websites access my language list
HKCU\Control Panel\International\User Profile\HttpAcceptLanguageOptOut 1
HKCU\SOFTWARE\Microsoft\Internet Explorer\International\AcceptLanguage #DELETE
#let apps use advertising id
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo\Enabled 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo\Id #DEL
#Let windows track app launches
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_TrackProgs 0
#Ink/Typing Personalization
HKCU\SOFTWARE\Microsoft\Personalization\Settings\AcceptedPrivacyPolicy 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language\Enabled 0
HKCU\SOFTWARE\Microsoft\InputPersonalization\RestrictImplicitTextCollection 1
HKCU\SOFTWARE\Microsoft\InputPersonalization\RestrictImplicitInkCollection 1
HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore\HarvestContacts 0
#Diagnostic data
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\ShowedToastAtLevel 1
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy\TailoredExperiencesWithDiagnosticDataEnabled 0
#feedback freq
HKCU\SOFTWARE\Microsoft\Siuf\Rules\NumberOfSIUFInPeriod 0
HKCU\SOFTWARE\Microsoft\Siuf\Rules\PeriodInNanoSeconds #DEL

#Notify about restarts
HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings\RestartNotificationsAllowed2 1

#Show hidden files
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Hidden 1
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt 0
#full path in title bar
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\DontPrettyPath 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideIcons 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideDrivesWithNoMedia 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState\FullPath 1
# show drive letters
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShowDriveLettersFirst 0
#cortana
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ShowCortanaButton 0
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\SearchboxTaskbarMode 0
# news on taskbar
HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds\ShellFeedsTaskbarViewMode 0






Write-Output "Reboot the shell to continue...."