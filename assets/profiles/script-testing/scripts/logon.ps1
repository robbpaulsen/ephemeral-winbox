#run updates and installs in the background
Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).ifIndex -ServerAddresses 1.1.1.1

## Antes de iniciar el nuevo proceso y tarea del instalador hay que avisar al sistema
## que momentaneamente ignore y asuma que el script o instalador cumple con los requisitos
## para ejecutarse.
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

$modules = @(
'BurntToast',
'Microsoft.WinGet.Client',
'PackageManagement',
'PowerShellGet',
'PSWindowsUpdate',
'PSReadLine',
'Terminal-Icons'
)
foreach ($module in ${modules}) {
    if (-not (Get-Module -ListAvailable -Name ${module})) {
        Install-Module -Name ${module} -Repository PSGallery -Scope CurrentUser -Force -SkipPublisherCheck
    }
    Import-Module -Name ${module} -Scope Local -Force
}

try {
    $progressPreference = 'silentlyContinue'
    Write-Host "Updating the SandBox"
    Get-WindowsUpdate -AcceptAll -ForceInstall -IgnoreReboot

    Write-Host "Done."
} catch {
    "⚠️ Error en linea $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
}; New-BurntToastNotification -Text "Ya esta listo el SandBox" -Sound SMS; New-BurntToastNotification -Text "Ya esta listo el SandBox" -Sound SMS

#log "Installing VSCode"
#Start-Job -name VSCode -FilePath (Join-Path -Path $SetupPath -ChildPath Install-vscodesandbox.ps1) @jobparams

#log "Updating Windows PowerShell Help"
#Start-Job -ScriptBlock { PowerShell -command { Update-Help -Force } ; log "Help updated" } @jobparams
#Start-Job -name "Help-Update" -ScriptBlock { Update-Help -Force  ; log "Help updated" } @jobparams

#log "Installing default modules: PSScriptTools, PSTeachingTools, BurntToast"
#Start-Job -name "Module-Install" -ScriptBlock {
#    Install-Module PSScriptTools, PSTeachingTools, BurntToast -Force ;
#     log "PowerShell modules installed" } @jobparams

#log "Installing PSReleaseTools and PowerShell 7 + Preview"
#Start-Job -name "PS7-Install" -ScriptBlock {
#    Install-Module PSReleaseTools -Force
#    $msi = (Get-Item C:\shared\PowerShell-7.1*.msi).FullName
#    Start-Process -FilePath $msi -ArgumentList "/quiet REGISTER_MANIFEST=1 ADD_PATH=1 ENABLE_PSREMOTING=1 ADD_EXPLORER_CONTEXT_MENU_OPENPowerShell=1 ADD_FILE_CONTEXT_MENU_RUNPowerShell=1"
#    $msi = (Get-Item C:\shared\PowerShell-7*preview*.msi).FullName
#    Start-Process -FilePath $msi -ArgumentList "/quiet REGISTER_MANIFEST=1 ADD_PATH=1 ENABLE_PSREMOTING=1 ADD_EXPLORER_CONTEXT_MENU_OPENPowerShell=1 ADD_FILE_CONTEXT_MENU_RUNPowerShell=1"
#
    #Install-PowerShell -Mode quiet -EnableRemoting -EnableContextMenu
    #Install-PSPreview -Mode quiet -EnableRemoting -EnableContextMenu
    #update help
#    C:\Program` Files\PowerShell\7\pwsh.exe -command { Update-Help -Force }
#    log "PowerShell 7 installed"
#} @jobparams

#log "Installing Windows Terminal"
#Start-Job -name "Windows-Terminal" -ScriptBlock { Install-Module WTToolbox -Force ; Install-WTRelease ; log "Windows Terminal installed" } @jobparams

#log "Configuring desktop settings"
#Start-Job -Name "Desktop-Config" -FilePath (Join-Path -Path $SetupPath -ChildPath Set-SandboxDesktop.ps1) @jobparams

#log "Installing Winget and additional apps"
#Start-Job -name "Winget" -ScriptBlock {
#    C:\scripts\Download-Winget.ps1 -install -AddPrequisites
#    winget install git
#    winget install microsoft.edge
#    log "Winget and other apps installed"
#} @jobparams

#wait for everything to finish
#log "Waiting for background jobs to complete"
#Get-Job | Wait-Job

#add jobs to the log
#Get-Job | ForEach-Object {
#    $msg = "Job: {0} {1} [{2}]" -f $_.name, $_.state, ( New-TimeSpan -Start $_.PSBeginTime -End $_.PSEndTime)
#    log $msg
#}

#log "Starting Windows Terminal"
#Start-Process wt.exe "-M new-tab -p PowerShell -d C:\ ; split-pane -V -p Windows PowerShell ; focus-tab --target 0"

#Log "Setting the host notification flag"
#Get-Date | Out-File -FilePath c:\scripts\sandbox.flag

#log "Sending toast notification in the Windows Sandbox"
#&(Join-Path -Path $SetupPath -ChildPath sandbox-toast.ps1)

#log "Ending configuration script $($MyInvocation.MyCommand)"
#log "Configuration completed in $(New-Timespan -start $begin)"
#log "Have a nice day!"
