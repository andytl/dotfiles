Set-StrictMode -Version Latest

$DefaultCredentialFileStore = "$env:USERPROFILE\Documents\EncryptedPasswordStore.txt"

<#
Password File schema
Host - Machine this is valid on
CredentialName - String identifying credential
EncryptedCredential - DPAPI encrypted key
#>

function TouchCredentialFile {
    param(
        $FileName
    )
    if (-not (Test-Path -Path $FileName)) {
        Set-Content -Path $FileName -Value "Host,CredentialName,EncryptedCredential" -Encoding UTF8
    }
}

function ReadCredentialFile {
    param(
        $FileName,
        $CredentialName
    )
    TouchCredentialFile $FileName
    $hostName = $(HOSTNAME.EXE)
    Get-Content -Raw -Path $FileName | ConvertFrom-Csv | Where-Object { ($_.Host -eq $hostName) -and ($_.CredentialName -eq $CredentialName) }
}

function  WriteCredentialFile {
    param (
        $FileName,
        $CredentialName,
        $CredentialSerializedSecuredString
    )
    TouchCredentialFile $FileName
    $hostName = $(HOSTNAME.EXE)
    $CredList = @(Get-Content -Raw -Path $FileName | ConvertFrom-Csv)
    $cred = $CredList | Where-Object { ($_.Host -eq $hostName) -and ($_.CredentialName -eq $CredentialName) }

    if ($cred) {
        $cred.EncryptedCredential = $CredentialSerializedSecuredString
    } else {
        $CredList += [PSCustomObject]@{
            Host = $hostName;
            CredentialName = $CredentialName;
            EncryptedCredential = $CredentialSerializedSecuredString
        }
    }
    $CredList | ConvertTo-Csv -NoTypeInformation | Set-Content -Path $FileName -Encoding UTF8
}


[CmdletBinding]
function Get-SecureCredentialFromFileStore {
    param(
        $CredentialName,
        $FileName = $DefaultCredentialFileStore
    )

    $credObject = ReadCredentialFile $FileName $CredentialName
    if ($credObject) {
        $credObject.EncryptedCredential | ConvertTo-SecureString
    } else {
        Update-SecureCredentialFromFileStore -CredentialName $CredentialName -FileName $FileName
    }
}

[CmdletBinding]
function Update-SecureCredentialFromFileStore {
    param(
        $CredentialName,
        [SecureString] $NewCredentialPassword = $null,
        $FileName = $DefaultCredentialFileStore
    )
    if (-not $NewCredentialPassword) {
        $NewCredentialPassword = Read-Host "Enter new secret for credential $CredentialName>" -AsSecureString
    }
    WriteCredentialFile $FileName $CredentialName (ConvertFrom-SecureString $NewCredentialPassword)

    (ReadCredentialFile $FileName $CredentialName).EncryptedCredential | ConvertTo-SecureString
}

Export-ModuleMember Get-SecureCredentialFromFileStore
Export-ModuleMember Update-SecureCredentialFromFileStore