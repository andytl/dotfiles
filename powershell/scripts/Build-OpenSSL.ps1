#building openssl
 #invoke these commands in a powershell window opened by vs2022powershellise.bat

& "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\Launch-VsDevShell.ps1" -HostArch amd64 -Arch amd64 

Set-Location $env:USERPROFILE\Source\Repos\openssl

Add-PathIfPresent $env:USERPROFILE\bin\strawberry-perl-5.32.1.1-64bit-portable\perl\site\bin
Add-PathIfPresent $env:USERPROFILE\bin\strawberry-perl-5.32.1.1-64bit-portable\perl\bin
Add-PathIfPresent $env:USERPROFILE\bin\strawberry-perl-5.32.1.1-64bit-portable\c\bin
Add-PathIfPresent $env:USERPROFILE\bin\nasm-2.16.01

perl Configure VC-WIN64A

nmake clean
nmake
#nmake install
#nmake uninstall



