#SingleInstance force

; Common Key for sendinput
; !{key} -> Alt + {key}
; ^{key} -> Ctrl + {key}
; 


#Include *i %A_MyDocuments%\AutoHotKeyU64_WorkSpecific.ahk

#h::
  Run notepad "%A_MyDocuments%\AutoHotKeyU64.ahk" ; "C:\Program Files (x86)\Vim\vim74\gvim.exe"
  Sleep 5000
  WinActivate, AutoHotKeyU64.ahk - Notepad
return

#y::
  Run notepad "%A_MyDocuments%\AutoHotKeyU64_WorkSpecific.ahk" ; "C:\Program Files (x86)\Vim\vim74\gvim.exe"
  Sleep 5000
  WinActivate, AutoHotKeyU64
return

#j::
  Reload
  Sleep 2000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
  MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
  IfMsgBox, Yes, Edit
return

#t::Run "C:\Program Files\ConEmu\ConEmu64.exe"
#p::SendInput . C:\Users\andlam\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1{Enter}

; Remap the windows movement to only require ctrl and not the winkey
;#9::SendInput,{Ctrl down}{LWin down}{Left}{Ctrl up}{LWin up}
;#0::SendInput,{Ctrl down}{LWin down}{Right}{Ctrl up}{LWin up}
;!Left::^#Left
;!Right::^#Right
Alt & 0::AltTab
Alt & 9::ShiftAltTab
;Ctrl & 0::SendInput {Ctrl down}{Tab}{Ctrl up}
;Ctrl & 9::SendInput {Ctrl down}{Shift down}{Tab}{Shift up}{Ctrl up}

Alt & -::AltTabMenuDismiss