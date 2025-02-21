<#
.Descripcion:
Setup, inicialización e instalación de las dependencias y paquetes para activar Windows Sand Box

.Autor:
Robbpaulsen

.Contacto:
https://github.com/robbpaulsen

.Ejecucion:

#>

# Winget installation
try {
    function AAP {
        param (
            [string]$pkg
        )
        Add-AppxPackage -ErrorAction:SilentlyContinue $pkg
    }

    function InstallPrereqs {
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
        Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
        AAP -pkg "Microsoft.VCLibs.x64.14.00.Desktop.appx"
        AAP -pkg "Microsoft.UI.Xaml.2.7.x64.appx"
    }
    function Get-LatestGitHubRelease {
        param (
            [int]$assetIndex
        )
        try {
            $response = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
            $latestVersion = $response.tag_name
            $assetUrl = $response.assets[$assetIndex].browser_download_url
            Invoke-WebRequest -Uri $assetUrl -OutFile Microsoft.DesktopAppInstaller.msixbundle
        }
        catch {
            Write-Warning $_
        }
    }

    function WingetCheck {
        if (-not (Get-Command -ErrorAction SilentlyContinue winget)) {
            InstallPrereqs
            Get-LatestGitHubRelease -assetIndex 2
            AAP -pkg "Microsoft.DesktopAppInstaller.msixbundle"
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        }
    }
    WingetCheck

    # Function to check and install Chocolatey
    function Install-Choco {
        if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
            Set-ExecutionPolicy Bypass -Scope Process -Force
        }
        else {
            Write-Output "`n⚠️ Chocolatey ya esta instalado."
        }
        catch {
            Write-Warning $_
        }
    }
    # Call the function to check/install Chocolatey
    Install-Choco
    function InstallApps {
        header -title "Instalando Aplicaciones..."
        $appsJson = ".\apps.json"
        winget import --accept-package-agreements --accept-source-agreements --disable-interactivity -i $appsJson
    }
    InstallApps
}
catch {
    Write-Warning $_
}
