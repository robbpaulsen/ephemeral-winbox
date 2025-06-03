<#
.Descripcion:
Setup, inicialización e instalación de las dependencias y paquetes para activar Windows Sand Box

.Autor:
Robbpaulsen

.Contacto:
https://github.com/robbpaulsen

.Ejecucion:

#>

#Requires -RunAsAdministrator

$IsAdmin = (New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]:: Administrator)
if (-not $IsAdmin) {
    Write-Output "`n⚠️ Necesitas ejecutar el script como Administrador y/o Desbloquear el Script." -ForegroundColor Green -BackgroundColor Black
    exit 1
}

New-Item -Path C:\ -Name WindowsSandBox -ItemType Directory -

try {
    Write-Output "`n⏳ Primero Actualizar el Sistema - " -ForegroundColor Yellow -NoNewline; Write-Output "[01]" -ForegroundColor Green -BackgroundColor Black
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    # Update PowerShell help and set execution policy to Bypass
    Update-Help -Force;
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force:$True -ErrorAction SilentlyContinue

    # Install required modules from PSGallery repository
    $modules = @(
        'BurntToast',
        'MSCatalog',
        'oh-my-posh-core',
        'PSWindowsUpdate',
        'TerminalIcons',
        'WindowsSandboxTools'
    )
    foreach ($module in $modules) {
        Install-Module -Name $module -Scope CurrentUser -AllowPrerelease -Repository PSGallery -Force
        Import-Module -Name $module -Scope Local -Force
    }

    # Download and install Windows updates
    Start-Process powershell.exe -WindowStyle Maximized -Verb RunAs -ArgumentList '-Version 5.0' '-NoExit' `
        '-WindowStyle Maximized' '-NoProfile' '-ExecutionPolicy ByPass' '-Command' 'Get-WindowsUpdate' `
        '-AcceptAll' '-ForceInstall' '-IgnoreReboot' '-MicrosoftUpdate' '-WindowsUpdate' '-Verbose' '-NoExit'
    | Out-File '$env:USERPROFILE\PSWindowsUpdate.log'
}
catch {
    "`n⚠️ Error in line $($Error[0].InvocationInfo.ScriptLineNumber): $($Error[0])"
}

try {
    # Display a progress bar and status message
    $status = "`n⏳ Se Habilitara la plataforma de Contenedores y Virtualización - "
    Write-Host $status -ForegroundColor Yellow -NoNewline

    # Output the progress bar with a green checkmark
    Write-Output "[02]" -ForegroundColor Green -BackgroundColor Black

    # Enable Windows features using Write-Progress and Enable-WindowsOptionalFeature
    Write-Progress -Activity 'Enable Windows Features' -Status "`n⏳ Habilitando Windows SandBox...⏳" `
        -CurrentOperation (Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online -NoRestart)
    Write-Progress -Completed
}
catch {
    "`n⚠️ Error in line $($Error[0].InvocationInfo.ScriptLineNumber): $($Error[0])"
}
