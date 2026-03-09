# Copyright (c) Raymond Clowe. All rights reserved.
# Licensed under the MIT License.
#
# Installation Script for Windows Terminal SSH Protocol Handler
# Github: https://github.com/raymondclowe/windows-terminal-ssh-protocol-handler/
#
# Install from web (one-liner):
#   irm https://raw.githubusercontent.com/raymondclowe/windows-terminal-ssh-protocol-handler/master/install.ps1 | iex

param(
    [string]$InstallPath = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Scripts")
)

$ErrorActionPreference = 'Stop'

$repoOwner  = 'raymondclowe'
$repoName   = 'windows-terminal-ssh-protocol-handler'
$scriptName = 'windows-terminal-ssh-protocol-handler.ps1'
$rawBaseUrl = "https://raw.githubusercontent.com/$repoOwner/$repoName/master"

Write-Host "Windows Terminal SSH Protocol Handler - Installer" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Create the install directory if it doesn't exist
if (-not (Test-Path $InstallPath)) {
    Write-Host "Creating install directory: $InstallPath"
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
}

# Download the handler script
$scriptDestination = Join-Path $InstallPath $scriptName
Write-Host "Downloading handler script to: $scriptDestination"
Invoke-WebRequest -Uri "$rawBaseUrl/$scriptName" -OutFile $scriptDestination -UseBasicParsing
Write-Host "Handler script downloaded successfully." -ForegroundColor Green

# Set up registry keys
Write-Host "Setting up registry keys..."

$handlerClass    = 'WTHandler.URLHandler.1'
$handlerClassKey = "HKCU:\SOFTWARE\Classes\$handlerClass"
$command         = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + $scriptDestination + '" "%1"'

# Create handler class keys
New-Item -Path "$handlerClassKey\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "$handlerClassKey\shell\open\command" -Name '(Default)' -Value $command

# Set capabilities
$capabilitiesPath = 'HKCU:\SOFTWARE\WTHandler\Capabilities'
New-Item -Path $capabilitiesPath -Force | Out-Null
Set-ItemProperty -Path $capabilitiesPath -Name 'ApplicationDescription' -Value 'Windows Terminal SSH Protocol Handler'
Set-ItemProperty -Path $capabilitiesPath -Name 'ApplicationName'        -Value 'Windows Terminal SSH Protocol Handler'

# Associate URL schemes
$urlAssocPath = "$capabilitiesPath\UrlAssociations"
New-Item -Path $urlAssocPath -Force | Out-Null
Set-ItemProperty -Path $urlAssocPath -Name 'ssh'  -Value $handlerClass
Set-ItemProperty -Path $urlAssocPath -Name 'ssh1' -Value $handlerClass
Set-ItemProperty -Path $urlAssocPath -Name 'ssh2' -Value $handlerClass

# Register the application
$regAppsPath = 'HKCU:\SOFTWARE\RegisteredApplications'
if (-not (Test-Path $regAppsPath)) {
    New-Item -Path $regAppsPath -Force | Out-Null
}
Set-ItemProperty -Path $regAppsPath -Name 'Windows Terminal SSH Protocol Handler' -Value 'Software\WTHandler\Capabilities'

# Suppress the association change toast notification for the ssh scheme
$toastsPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts'
if (-not (Test-Path $toastsPath)) {
    New-Item -Path $toastsPath -Force | Out-Null
}
Set-ItemProperty -Path $toastsPath -Name "${handlerClass}_ssh" -Value 0 -Type DWord

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Script installed to: $scriptDestination"
Write-Host ""
Write-Host "The ssh:// protocol will now open connections in Windows Terminal."
Write-Host "Note: You may need to restart your browser for the protocol association to take effect."
