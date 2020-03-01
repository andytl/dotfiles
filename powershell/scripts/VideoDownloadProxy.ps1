 <#

 https://www.socks-proxy.net/

 @"
 "@ > .\proxies.tsv
$videoUrl = "http://www.youtube.com/watch?v=hEx_-qulYmI"

#>

<#
Downloads video using proxies in provided list.

#>
param (
    $videoUrl
)


$proxies = Get-Content -Raw .\proxies.tsv
$proxiesList = ConvertFrom-Csv $proxies -Delimiter "`t"
$proxiesListIndex = 0;

$exitcode = 1
while($exitcode -ne 0) {
    $proxy = $proxiesList[$proxiesListIndex]
    $proxyParam = "socks4://$($proxy.'IP Address'):$($proxy.'Port')"
    $proxiesListIndex++
    Write-Output $proxy.'Country'
    Write-Output $proxyParam

    youtube-dl $videoUrl --proxy $proxyParam --socket-timeout 10
    $exitcode = $LASTEXITCODE
}





$exitcode = 1
while($exitcode -ne 0) {
    $proxyParam = "socks4://176.120.210.153:4145"

    youtube-dl $videoUrl --proxy $proxyParam
    $exitcode = $LASTEXITCODE
}