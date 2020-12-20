#SingleInstance force

; Ctrl would result in WinKey+Ctrl mask conflicting with Windows Speech Recognition.
#MenuMaskKey vk07

; Common Key for sendinput
; !{key} -> Alt + {key}
; ^{key} -> Ctrl + {key}
; 


#Include *i %A_MyDocuments%\AutoHotKeyU64_WorkSpecific.ahk

#j::
  Run notepad "%A_MyDocuments%\AutoHotKey.ahk" ; "C:\Program Files (x86)\Vim\vim74\gvim.exe"
  Sleep 5000
  WinActivate, AutoHotKey.ahk - Notepad
return

#u::
  Run notepad "%A_MyDocuments%\AutoHotKeyU64_WorkSpecific.ahk" ; "C:\Program Files (x86)\Vim\vim74\gvim.exe"
  Sleep 5000
  WinActivate, AutoHotKey
return

#k::
  Reload
  Sleep 2000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
  MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
  IfMsgBox, Yes, Edit
return

#t::Run,C:\Program Files\ConEmu\ConEmu64.exe -run {Shells::PowerShell}
#+t::Run,C:\Program Files\ConEmu\ConEmu64.exe -run {Shells::PowerShell (Admin)}
#p::SendInput . C:\Users\andlam\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1{Enter}

#s::Run, *RunAs "C:\Program Files (x86)\FileZilla Server\FileZilla Server.exe" /start
#+s::Run, *RunAs "C:\Program Files (x86)\FileZilla Server\FileZilla Server.exe" /stop

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

Alt & y::SendInput y{Enter}
Alt & n::SendInput n{Enter}

!Numpad0::SendInput {Media_Play_Pause}
!NumpadIns::SendInput {Media_Play_Pause}
!Numpad4::SendInput {Media_Prev}
!NumpadLeft::SendInput {Media_Prev}
!Numpad6::SendInput {Media_Next}
!NumpadRight::SendInput {Media_Next}
!NumpadAdd::SoundSet +5
!NumpadSub::SoundSet -5