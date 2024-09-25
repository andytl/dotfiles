
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
        $shortcutFile,
        $targetFile,
        $shortcutArgs
    )
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutFile)
    $Shortcut.TargetPath = $targetFile
    if ($shortcutArgs) {
        $Shortcut.Arguments = $shortcutArgs
    }
    $Shortcut.Save()
}

function WingetInstall {
    param (
        $searchType,
        $appname
    )
    winget install --accept-source-agreements --accept-package-agreements --source winget "--$searchType" $appname
}

#Update winget
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

WingetInstall id Microsoft.Sysinternals.ProcessMonitor
WingetInstall id Mozilla.Firefox
WingetInstall id Notepad++.Notepad++
WingetInstall id 7zip.7zip
WingetInstall moniker Python3
WingetInstall id AutoHotkey.AutoHotkey
WingetInstall id VideoLAN.VLC
WingetInstall id Git.Git
WingetInstall id Microsoft.VisualStudioCode

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

# Install VSCode extensions
RefreshPath
Invoke-Command { code --install-extension ms-vscode.powershell } -ErrorAction SilentlyContinue
Invoke-Command { code --install-extension ms-vscode.cpptools } -ErrorAction SilentlyContinue
Invoke-Command { code --install-extension streetsidesoftware.code-spell-checker } -ErrorAction SilentlyContinue

<#

if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
    choco install vim
    git clone https://github.com/VundleVim/Vundle.vim.git $env:USERPROFILE\.vim\bundle\Vundle.vim
    # TODO Fork this repo and use own copy for security.
    #git clone https://github.com/sickill/vim-monokai.git $env:USERPROFILE\vimfiles\colors\monokai_repo
    #Copy-Item $env:USERPROFILE\vimfiles\colors\monokai_repo\colors\*  $env:USERPROFILE\vimfiles\colors\
}
#>

$ahkShortcutPath = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey.lnk"
if (-not (Test-Path $ahkShortcutPath)) {
    CreateShortcut  $ahkShortcutPath 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' " $env:USERPROFILE\Documents\Autohotkey.ahk"
}





function GetDotfileRepo {
    Write-Output "GetDotfileRepo"
    New-Item -ItemType Directory -Path "$env:USERPROFILE\Source\Repos" -Force > $null
    #ssh-keygen.exe -q -f "$env:USERPROFILE\.ssh\id_rsa" -t rsa -N '""'
    $repoDir = "$env:USERPROFILE\Source\Repos\dotfiles"
    #(ssh-keyscan github.com) | Out-File  ~\.ssh\known_hosts -Append
    git config --global core.autocrlf false
    git clone "https://github.com/andytl/dotfiles.git" $repoDir
    python "$repoDir\import.py" $env:USERPROFILE $repoDir import
}
if (-not (Test-Path "$env:USERPROFILE\Source\Repos\dotfiles")) {
    RefreshPath
    GetDotfileRepo
}

# Remove Windows junk
<#
$keep = "(Microsoft|Windows|NVIDIA|Realtek|Intel|AMD|PaloAltoNetworks)";
$apps = (Get-AppxPackage | ? { $_.PackageFullName -notmatch "^$keep|\.$keep" -and $_.Publisher -notmatch "$keep" })
Write-Output "Removing apps:"
($apps).PackageFullName
$apps | Remove-AppPackage
#>

# For registry keys, ignore delete failures
$ErrorActionPreference = "Continue"
# Apply custom registry settings
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Search /v BingSearchEnabled /t REG_DWORD /d 0 /f  
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Search /v AllowSearchToUseLocation /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Search /v CortanaConsent /t REG_DWORD /d 0 /f

# Disable Aero Peek
REG ADD "HKCU\SOFTWARE\Microsoft\Windows\DWM" /V EnableAeroPeek /T REG_DWORD /D 0 /F


#Disable windows welcome experience after updates, and disable new/suggested
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v SubscribedContent-310094Enabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement /v ScoobeSystemSettingEnabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v SubscribedContent-338382Enabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v SubscribedContent-353699Enabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers /v DisableAutoplay /t REG_DWORD /d 1 /f
#show suggestions in settings
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v SubscribedContent-338386Enabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v SubscribedContent-353695Enabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v SubscribedContent-353697Enabled /t REG_DWORD /d 0 /f
#show suggestions in start
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v SubscribedContent-338381Enabled /t REG_DWORD /d 0 /f

#show content on lock screen
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v RotatingLockScreenEnabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v SubscribedContent-338380Enabled /t REG_DWORD /d 0 /f

$sid = (([Security.Principal.WindowsIdentity]::GetCurrent()).User.Value)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Creative\$sid" /v RotatingLockScreenEnabled /t REG_DWORD /d 0 /f



#show recently opened items in start/quick access
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Start_TrackDocs /t REG_DWORD /d 0 /f
#start notifications and reccomendations
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Start_AccountNotifications /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Start_IrisRecommendations /t REG_DWORD /d 0 /f

reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v AppsUseLightTheme /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize /v SystemUsesLightTheme /t REG_DWORD /d 0 /f
#badges on taskbar buttons
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarBadges /t REG_DWORD /d 0 /f
#gamebar
reg add HKCU\SOFTWARE\Microsoft\GameBar /v UseNexusForGameBarEnabled /t REG_DWORD /d 0 /f
#gamemode
reg add HKCU\SOFTWARE\Microsoft\GameBar /v AutoGameModeEnabled /t REG_DWORD /d 0 /f
#search settings
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings /v IsMSACloudSearchEnabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings /v IsAADCloudSearchEnabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings /v IsDeviceSearchHistoryEnabled /t REG_DWORD /d 0 /f
    #show suggestions in search
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings /v IsDynamicSearchBoxEnabled /t REG_DWORD /d 0 /f
#let websites access my language list
reg add "HKCU\Control Panel\International\User Profile" /v HttpAcceptLanguageOptOut /t REG_DWORD /d 1 /f
reg add "HKCU\SOFTWARE\Microsoft\Internet Explorer\International" /v AcceptLanguage /f
#let apps use advertising id
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo /v Enabled /t REG_DWORD /d 0 /f
reg delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo /v Id /f
#Let windows track app launches
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Start_TrackProgs /t REG_DWORD /d 0 /f
#Ink/Typing Personalization
reg add HKCU\SOFTWARE\Microsoft\Personalization\Settings /v AcceptedPrivacyPolicy /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language /v Enabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\InputPersonalization /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\InputPersonalization /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore /v HarvestContacts /t REG_DWORD /d 0 /f
#Diagnostic data
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack /v ShowedToastAtLevel /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f
#feedback freq
reg add HKCU\SOFTWARE\Microsoft\Siuf\Rules /v NumberOfSIUFInPeriod /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Siuf\Rules /v PeriodInNanoSeconds /f

#Notify about restarts
reg add HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings /v RestartNotificationsAllowed2 /t REG_DWORD /d 1 /f

#Show hidden files
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v "Hidden" /t REG_DWORD /d 1 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f
#full path in title bar
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v DontPrettyPath /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideIcons /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideDrivesWithNoMedia /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState /v FullPath /t REG_DWORD /d 1 /f
# show drive letters
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer /v ShowDriveLettersFirst /t REG_DWORD /d 0 /f
# edge tabs on alt-tab
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v MultiTaskingAltTabFilter /t REG_DWORD /d 3 /f
#cortana
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v ShowCortanaButton /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f

# dont show recents on start
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Start /v ShowRecentList /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Start_Layout /t REG_DWORD /d 0 /f

#Taskbar settings
    # news on taskbar
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarMn /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarDa /t REG_DWORD /d 0 /f
    # Left align taskbar
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarAl /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarFlashing /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarSh /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarSn /t REG_DWORD /d 0 /f

#disable Dynamic Lighting - ambient lighting
reg add HKCU\Software\Microsoft\Lighting /v AmbientLightingEnabled /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\Lighting /v ControlledByForegroundApp /t REG_DWORD /d 0 /f



Write-Output "Reboot the shell to continue...."