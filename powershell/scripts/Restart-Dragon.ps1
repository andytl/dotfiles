
Get-Process natspeak | Stop-Process -force
Get-Process dragonbar | Stop-Process -force
Get-Process dgnuiasvr* | Stop-Process -force
Get-Process dgnuiasvr_x64 | Stop-Process -force
Get-Process dgnria_emhost* | Stop-Process -force
Get-Service DragonSvc | Stop-Service
Get-Service DragonLoggerService | Stop-Service

Get-Service DragonSvc | Start-Service
Get-Service DragonLoggerService | Start-Service
explorer.exe "C:\Program Files (x86)\Nuance\NaturallySpeaking15\Program\natspeak.exe"
