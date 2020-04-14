[CmdletBinding()]
param (
    [string] $command
)

$sshHost = "linuxtest@192.168.1.11"

if ($command -match "s$|start") {
    Start-VM -Name "LinuxTest"
    ssh $sshHost "sudo docker run --name rtmpserver --rm -d -p 42068:1935 -p 8080:8080 jasonrivers/nginx-rtmp"
} elseif ($command -match "st$|stop") {
    ssh $sshHost "sudo docker stop rtmpserver"
    Start-Sleep 10
    Save-VM -Name "LinuxTest"
} elseif ($command -match "q$|query") {
    ssh $sshHost "sudo docker logs --follow rtmpserver"
} else {
    Write-Output "commands: [s]tart [st]op [q]uery"
}


#Start-VM -Name "LinuxTest"
<#


while($true) {
    if ([Console]::KeyAvailable -and [Console]::ReadKey($true).KeyChar -eq 's')
    {
        break;
    }
    [Console]::Clear()
    Write-Output "Server Running (press s to stop)"
    Write-Output ""
    Write-Output "Last 20 lines of log:"
    ssh $sshHost "sudo docker logs --tail 20 rtmpserver"


    Start-Sleep -Seconds 1
}

ssh $sshHost "sudo docker stop rtmpserver"

echo "Stopped"
#>