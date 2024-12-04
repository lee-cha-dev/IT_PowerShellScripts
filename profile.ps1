# Copyright © 2024 Lee Charles
# All Rights Reserved.
#
# This script is licensed for personal and educational use only.
# Commercial use is strictly prohibited without prior written consent and
# agreement on royalties or purchase. Redistribution, modification, or 
# inclusion in proprietary works without explicit permission is also prohibited.
#
# DISCLAIMER:
# This script is provided "as is," without warranty of any kind. Use at your own risk.
# It is assumed that the user has a mid-to-senior level software engineering skillset.
# The author is not liable for any damage, data loss, or other issues arising
# from the use or misuse of this script.
#
# Purpose: IT Tier 1/2 task automation.

# Vars & Data that cannot be uploaded to GitHub (ensure sanitization by creating a var here)
$DevPath="C:\Users\charleskristopher\Box\Personal\dev\PowerShellScripts\LoadIntoProfile"
Write-Host "Dev File Path: $DevPath`n" -ForegroundColor Cyan

# Mount profile scripts for quick execution later
# "---loading user scripts---" | Write-Ascii -ForegroundColor Rainbow -Compress
$lenToAdd = [math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20
Write-Host (("-" * [math]::Floor($Host.UI.RawUI.WindowSize.Width/5)) + "Loading User Scripts" + ("-" * [math]::Floor($Host.UI.RawUI.WindowSize.Width/5))) -ForegroundColor Blue
# Write-Host ("-" * ($Host.UI.RawUI.WindowSize.Width/2))
if (Test-Path $DevPath){
    Get-ChildItem -Path $DevPath -Filter *.ps1 | ForEach-Object {
        try {
            . $_.FullName
            Write-Host "Loaded: $($_.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Unable to load: $($_.Name)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Scripts directorys not found: $DevPath" -ForegroundColor Red
}
Write-Host ("-" * ($lenToAdd))
