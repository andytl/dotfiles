<#
Dependencies
nodejs, steamcmd in your path


#>


Import-Module "Personal\Common"

$fireWallRuleName = "SvenCoopDedicatedServer"
$serverDir = Join-Path $env:USERPROFILE "\Documents\svencoopds"
$severExe = Join-Path $serverDir svends.exe
$downloadSvrDir = Join-Path $serverDir "downloadserver"
$downloadSvrJs = Join-Path $downloadSvrDir "server.js"
$configPath = "$serverDir\svencoop\server.cfg"
$mapConfigPath = "$serverDir\svencoop\mapvote.cfg"
$mapCyclePath = "$serverDir\svencoop\mapcycle.txt"
$ipaddr = Get-MachineIpAddress

function BackupFile {
    param($file)
    if (-not (Test-Path "$file.bak")) {
        Copy-Item $file "$file.bak"
    }
}


if (-not (Test-Path $serverDir)) {
    steamcmd +login anonymous +force_install_dir $serverDir +app_update 276060 validate +exit
}

#Must be in folder or else server breaks soundcache
Set-Location $serverDir

if (-not (Get-NetFirewallRule -DisplayName "SvenCoopDedicatedServer" -ErrorAction SilentlyContinue)) {
    Start-CommandTxtAsAdmin "New-NetFirewallRule -DisplayName $fireWallRuleName -Direction Inbound -Program $severExe -Action Allow"
    Write-Output "Accept firewall prompt"
}

if (-not (Test-Path $downloadSvrDir)) {
    New-Item -Path $downloadSvrDir -ItemType Directory -Force
    Push-Location $downloadSvrDir
    npm install express 2>&1
    Pop-Location
}

BackupFile $mapConfigPath
BackupFile $configPath
BackupFile $mapCyclePath

@"
var process = require('process');
var express = require('express');
var server = express();
// node server.js <path>
var path = process.argv[2].replace("\\\\", "/");

console.log("process.argv[2]: " + process.argv[2]);
console.log("Using " + path);
server.all("*", function (req, res, next) {
    console.log([req.ip, req.method, req.originalUrl].join(" "))
    next() // pass control to the next handler
});
server.use('/svencoopstatic', express.static(path));
//server.use(express.static(__dirname + '/public'));

server.listen(8080, () => {
    console.log('Server connected');
});
"@ | Out-File -FilePath $downloadSvrJs -Encoding utf8

((Get-Content -Path $configPath -Raw) -replace "sv_downloadurl.*","sv_downloadurl `"http://$ipaddr`:8080/svencoopstatic`"") |
    Set-Content -Path $configPath

<#
http://www.svencoop.com/manual/server-config.html
mapvote.cfg 	Location of the file containing a list of maps available for voting. Exceeding 200 maps may prevent players joining due to "reliable channel overflowed"!

Add maps to vote cfg
TODO: handle overflow of 200 files
TODO: add downloaded maps to votelist
#>

#Copy mapvote to mapcycle
Get-Content -Path $mapConfigPath | ForEach-Object { $_ -replace "addvotemap ","" } | Set-Content -Path $mapCyclePath

Read-Host "Ready to start server, update configs if needed and press enter" > $null

Start-Process node -ArgumentList @($downloadSvrJs, (Join-Path $serverDir "\svencoop_addon"))
& $severExe -console -port 27015 +maxplayers 8 +map afraidofmonsters_lobby +log on +ip $ipaddr