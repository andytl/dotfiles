param
(
    [Parameter(Mandatory=$true)]
    $vmName,
    $vmFolder,
    $vmImage,
    $autoUnattendString,
    [switch] $gptMode
)

Import-Module "Personal\Common"
# Resources are expected to be in a folder .\CreateHyperVVm\ relative to the location of this script.
$scriptRoot = Split-Path -Parent $PSCommandPath

function RemoteRunScriptBlock {
    param (
        [string] $scriptBlockText
    )
    Set-Location C:\schannel\AMD64
    & ([ScriptBlock]::Create($scriptBlockText))
}

function HyperVSetup {
    param (
        $vmName,
        $vmFolder,
        $vmImage,
        $autoUnattendString
    )
    #TODO: TEST
    #TODO: TEST

    # Use the first external switch in hyperv
    $networkSwitchName = (Get-VMSwitch | Where-Object { $_.SwitchType -eq "External" })[0].Name

    # Setup VHD
    Write-Output "Creating VM $vmName in $vmFolder"
    New-Item -Path $vmFolder  -ItemType Directory > $null
    $vhdPath = Join-Path $vmFolder "$vmName.vhdx"
    $vhdObject = New-VHD -Path $vhdPath -Dynamic -SizeBytes 127GB

    Write-Output "Creating VM in HyperV"
    if ($gptMode) {
        $generation = 2
        $partitionStyle = "GPT"
    } else {
        $generation = 1
        $partitionStyle = "MBR"
    }
    $vmObject = New-Vm -Name $vmName -MemoryStartupBytes 4GB -Generation $generation -Path $vmFolder -VHDPath $vhdPath
    Set-VMProcessor $vmName -Count 2
    Set-VMMemory $vmName -DynamicMemoryEnabled $false
    Connect-VMNetworkAdapter -VMName $vmName -Name "Network Adapter" -SwitchName $networkSwitchName
    $bootDrive = Add-VMDvdDrive -VM $vmObject -Passthru
    #Set-VMFirmware -VM $vmObject -BootOrder (Get-VMHardDiskDrive -VM $vmObject),$bootDrive
    if ($gptMode) {
        Set-VMFirmware -VM $vmObject -BootOrder $bootDrive
    } else {
        Set-VMBios -VM $vmObject -StartupOrder @("CD", "IDE", "Floppy", "LegacyNetworkAdapter")
    }
    Set-VMDvdDrive -VMDvdDrive $bootDrive -Path $vmImage
    
    # Produce Unattend file
    $unattendImagePath = Join-Path $vmFolder "unattend.vhdx"
    $unattendVHDObject = New-VHD -Path $unattendImagePath -SizeBytes 512MB -Dynamic
    try {
        $mountedVHD = Mount-VHD -Path $unattendImagePath -Passthru
        Initialize-Disk -Number $mountedVHD.DiskNumber -PartitionStyle $partitionStyle
        $partition = New-Partition -AssignDriveLetter -UseMaximumSize -DiskNumber $mountedVHD.DiskNumber
        $volume = Format-Volume -Partition $partition -FileSystem NTFS -Confirm:$false -Force
        $autoUnattendString | Out-File -FilePath "$($volume.DriveLetter):\autounattend.xml" -Encoding utf8
    } finally {
        Dismount-VHD -Path $unattendImagePath
    }
    Add-VMHardDiskDrive -VMName $vmName -Path $unattendImagePath 

    <#
    # Mount disk to apply offline changes
    Write-Output "Mount VHD and apply changes"
    $mountedDisk = Mount-VHD $vhdPath -Passthru
    $driveLetter = ($mountedDisk | Get-Disk | Get-Partition).DriveLetter

    ApplyVHDChanges $vmName $hvVmFolder $driveLetter $networkSwitchName $buildRoot
        
    DisMount-VHD $vhdLocalPath
    Write-Output "Finsihed VHD changes"
    # Finished apply offline changes

    #$vm = Get-VM -Name $vmName
    #Checkpoint-VM -Name $vmName -SnapshotName "BeforeFirstBoot"
    #>

    Start-VM -Name $vmName
    
    Wait-VM -Name $vmName -For IPAddress
    while ((Get-VM $vmName).Heartbeat -notmatch "^Ok") {
        Start-Sleep -Seconds 1
    }
    #$function:RemotePostBootSetup
}



$oldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Inquire"

H

$ErrorActionPreference = $oldErrorActionPreference
