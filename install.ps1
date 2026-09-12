# VITTweaks Installer

$repo = "https://raw.githubusercontent.com/vittweaks/VITTweaks/main/vittweaks.ps1"

Write-Host "==========================================" -ForegroundColor Magenta
Write-Host "           VITTweaks Installer" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Magenta

Invoke-Expression (Invoke-RestMethod $repo)
