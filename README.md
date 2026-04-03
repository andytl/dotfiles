# dotfiles

## Windows
```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/andytl/dotfiles/master/setupwindows.ps1" -OutFile ".\setupwindows.ps1"
.\setupwindows.ps1
```

# Linux/Mac
Can set `git config core.fileMode false` to avoid permission changes on the repo.
