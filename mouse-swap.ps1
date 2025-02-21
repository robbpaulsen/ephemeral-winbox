REM Download and install Visual Studio Code
curl -fsSL "https://update.code.visualstudio.com/latest/win32-x64-user/stable" --output C:\temp\vscode.exe
C:\temp\vscode.exe /verysilent /suppressmsgboxes

REM Run PowerShell script for mouse configuration
powershell.exe -ExecutionPolicy Bypass -File C:\sandbox\SwapMouseButton.ps1
