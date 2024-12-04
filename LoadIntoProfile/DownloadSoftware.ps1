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

function Downloads(){
    $downloads =
        "DownloadVMWare",
        "DownloadGlobalProtect",
        "DownloadAdobeAcrobat"

    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
    # Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width) | Out-Host  
    Write-Host "Available Downloads:`n" -ForegroundColor Cyan | Out-Host
    foreach ($d in $downloads){
        Write-Host "$d" -ForegroundColor DarkYellow
    }
    Write-Host "`nEach download will require the HostName and DomainName`nI.E. DownloadVMWare DAMB1234 smithjohn" -ForegroundColor Cyan
    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
}


function DownloadVMWare(){
    [CmdletBinding()]
    param (
        [string]$HostName,
        [string]$DomainName
    )

    if((ValidateHostName $HostName)){
        Invoke-Command -ComputerName $HostName -ScriptBlock {
            # Pass in domain name
            param($DomainName = $using:DomainName)

            # Download and Install Zoom
            # Force TLS 1.2
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            $installer = "C:\Users\$DomainName\Downloads\VMWareInstaller_2212.exe"
            
            try {
                Write-Host "VMWare Downloading.." -ForegroundColor Blue | Out-Host
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile("https://download3.omnissa.com/software/CART23FQ4_WIN_2212.1/VMware-Horizon-Client-2212.1-8.8.1-21249081.exe", $installer)
                Write-Host "VMWWare has been downloaded.`n" -ForegroundColor Green

                if (Test-Path $installer){
                    Write-Host "VMWWare Verified At: $installer"
                    # Creating Shortcut
                } else {
                    Write-Host "VMWWare installer not found at: $installer" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "Error downloading VMWare: $($_.Exception.Message)" -ForegroundColor Red | Out-Host
                Write-Host "Find the download at: https://download3.omnissa.com/software/CART23FQ4_WIN_2212.1/VMware-Horizon-Client-2212.1-8.8.1-21249081.exe" -ForegroundColor Cyan
            }
            Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20)) | Out-Host  
        }
    }
}

function DownloadGlobalProtect(){
    [CmdletBinding()]
    param (
        [string]$HostName,
        [string]$DomainName
    )

    if((ValidateHostName $HostName)){
        Invoke-Command -ComputerName $HostName -ScriptBlock {
            # Pass in domain name
            param($DomainName = $using:DomainName)

            # Download and Install GlobalProtect
            # Force TLS 1.2
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            $installer = "C:\Users\$DomainName\Downloads\GlobalProtect.msi"
            
            try {
                Write-Host "GlobalProtect Downloading.." -ForegroundColor Blue | Out-Host
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile("URL.COM/installer.exe", $installer)
                Write-Host "GlobalProtect has been downloaded.`n" -ForegroundColor Green

                if (Test-Path $installer){
                    Write-Host "GlobalProtect Verified At: $installer"
                    # Creating Shortcut
                } else {
                    Write-Host "GlobalProtect installer not found at: $installer" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "Error downloading GlobalProtect: $($_.Exception.Message)" -ForegroundColor Red | Out-Host
                Write-Host "Find the download at: URL.COM/installer.exe" -ForegroundColor Cyan
            }
            Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20)) | Out-Host  
        }
    }
}

function DownloadAdobeAcrobat(){
    [CmdletBinding()]
    param (
        [string]$HostName,
        [string]$DomainName
    )

    if((ValidateHostName $HostName)){
        Invoke-Command -ComputerName $HostName -ScriptBlock {
            # Pass in domain name
            param($DomainName = $using:DomainName)

            # Download and Install AdobeAcrobat
            # Force TLS 1.2
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            $installer = "C:\Users\$DomainName\Downloads\AdobeAcrobat_Installer.exe"
            
            try {
                Write-Host "AdobeAcrobat Downloading.." -ForegroundColor Blue | Out-Host
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile(
                    "https://get.adobe.com/reader/download?os=Windows+10&name=Reader+2024.004.20220+English+Windows%2864Bit%29&lang=en&nativeOs=Windows+10&accepted=&declined=mss&preInstalled=&site=landing",
                     $installer
                )
                Write-Host "AdobeAcrobat has been downloaded.`n" -ForegroundColor Green

                if (Test-Path $installer){
                    Write-Host "AdobeAcrobat Verified At: $installer"
                    # Creating Shortcut
                } else {
                    Write-Host "AdobeAcrobat installer not found at: $installer" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "Error downloading AdobeAcrobat: $($_.Exception.Message)" -ForegroundColor Red | Out-Host
                Write-Host "Find the download at: https://get.adobe.com/reader/download?os=Windows+10&name=Reader+2024.004.20220+English+Windows%2864Bit%29&lang=en&nativeOs=Windows+10&accepted=&declined=mss&preInstalled=&site=landing" -ForegroundColor Cyan
            }
            Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20)) | Out-Host
        }
    }
}