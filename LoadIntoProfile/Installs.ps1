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

function Installs(){
    Write-Host ("-" * ($Host.UI.RawUI.WindowSize.Width/2)) | Out-Host
    Write-Host "Install Assistance available on:`n" -ForegroundColor Cyan
    Write-Host "RightFax`nSAS`nSPSS`nMitel`n" -ForegroundColor DarkYellow
    Write-Host ("-" * ($Host.UI.RawUI.WindowSize.Width/2)) | Out-Host
}

function ParseJson {
    [CmdletBinding()]
    param (
        [string]$Name
    )
    # $scriptDirectory = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
    $jsonFilePath = Join-Path -Path $DevPath -ChildPath "install_paths.json"
    if (Test-Path $jsonFilePath){
        $installPaths = Get-Content -Path $jsonFilePath | ConvertFrom-Json
    } else {
        Write-Host "Could not open JSON file at: $jsonFilePath" -ForegroundColor Red
        return
    }
    Write-Host "Successfully opened json file: $jsonFilePath"

    # pass the json and return the path depending on switch statement
    switch ($Name) {
        "RightFax" {
            $path = $installPaths.RightFax.path
            $installer = $installPaths.RightFax.installer
            $doc = $installPaths.RightFax.doc

            Write-Host "`nRightFax Path: $path" -ForegroundColor Cyan
            Write-Host "Installer Path: $installer" -ForegroundColor Cyan
            Write-Host "Document Path: $doc" -ForegroundColor Cyan
            Write-Host "Server Name: Server1`n" -ForegroundColor Cyan
         }
         "SAS" {
            $path = $installPaths.SAS.path
            $installer = $installPaths.SAS.installer
            $doc = $installPaths.SAS.doc

            Write-Host "`nSAS Path: $path" -ForegroundColor Cyan
            Write-Host "Installer Path: $installer" -ForegroundColor Cyan
            Write-Host "Document Path: $doc`n" -ForegroundColor Cyan
         }
         "SPSS" {
            $path = $installPaths.SPSS.path
            $installer = $installPaths.SPSS.installer
            $doc = $installPaths.SPSS.doc

            Write-Host "`nSPSS Path: $path" -ForegroundColor Cyan
            Write-Host "Installer Path: $installer" -ForegroundColor Cyan
            Write-Host "Document Path: $doc`n" -ForegroundColor Cyan
         }
         "Mitel" {
            $path = $installPaths.Mitel.path
            $installer = $installPaths.Mitel.installer
            $doc = $installPaths.Mitel.doc

            Write-Host "`nMitel Path: $path" -ForegroundColor Cyan
            Write-Host "Installer Path: $installer" -ForegroundColor Cyan
            Write-Host "Document Path: $doc" -ForegroundColor Cyan
            Write-Host "Server Name: ServerName2`n" -ForegroundColor Cyan
         }
        Default {
            Write-Host "No installs by that name..try one of the following:`n"
            $installPaths.PSObject.Properties.Name | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
            return
        }
    }

    # open explorer at path
    try {
        if (Test-Path $path){
            Start-Process -FilePath "explorer.exe" -ArgumentList $path
        } else {
            Write-Host "Could not open '$path' in Explorer." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "The specified path does not exist: $path" -ForegroundColor Red
    }

    # open install docs
    try {
        if (Test-Path $doc){
            Start-Process -FilePath $doc
        } else {
            Write-Host "This file '$doc' does not exist" -ForegroundColor Red
        }                
    }
    catch {
        Write-Host "Could not open the install doc at: $doc" -ForegroundColor Red
    }
}

function RightFax {
    ParseJson "RightFax"
}

function SAS {
    ParseJson "SAS"
}

function SPSS {
    ParseJson "SPSS"
}

function Mitel {
    ParseJson "Mitel"
}