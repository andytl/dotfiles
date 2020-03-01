Import-Module "Personal\Common"

$fireWallRuleName = "SvenCoopDedicatedServer"
$serverDir = Join-Path $env:USERPROFILE "\Documents\svencoopds"
$severExe = Join-Path $serverDir svends.exe

if (-not (Test-Path $serverDir)) {
    steamcmd +login anonymous +force_install_dir $serverDir +app_update 276060 validate +exit
}


if (-not (Get-NetFirewallRule -DisplayName "SvenCoopDedicatedServer" -ErrorAction SilentlyContinue)) {
    Start-CommandTxtAsAdmin "New-NetFirewallRule -DisplayName $fireWallRuleName -Direction Inbound -Program $severExe -Action Allow"
    Write-Output "Accept firewall prompt"
}


$ipaddr = Get-MachineIpAddress
#Must be in folder or else server breaks soundcache
Set-Location $serverDir
& $severExe -console -port 27015 +maxplayers 8 +map afraidofmonsters_lobby +log on +ip $ipaddr