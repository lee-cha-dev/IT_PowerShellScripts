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

function UpgradeZoomHelper(){
    # Kill Zoom if it is up
    $zoomProc = Get-Process -Name "Zoom*" -ErrorAction SilentlyContinue
    if ($zoomProc){
        Write-Host "Terminating Zoom processes.." -ForegroundColor Blue | Out-Host
        Stop-Process -Name "Zoom*" -Force
        Write-Host "Zoom processes have been terminated." -ForegroundColor Green | Out-Host
    } else {
        Write-Host "There are no Zoom processes currently running." -ForegroundColor Yellow
    }

    # Get current logged in user
    try {
        # Attempt to get the currently logged-in user
        $logged_in = (Get-WmiObject -Class Win32_ComputerSystem).UserName
    
        if ($null -eq $logged_in) {
            throw "No user is currently logged in or the retrieval failed."
        }
        $DomainName = $logged_in.split("\")[1]
        Write-Host "The current logged-in user is: $DomainName"
    } catch {
        # Handle errors
        Write-Host "An error occurred: $_"
    }
    
  
    # Uninstall Zoom
    $zoomUninstallPaths = @(
        # User-specific locations
        "C:\Users\$DomainName\AppData\Roaming\Zoom\uninstall\Installer.exe",
        "C:\Users\$DomainName\AppData\Local\Zoom\uninstall\Installer.exe",
        "C:\Users\$DomainName\AppData\LocalLow\Zoom\uninstall\Installer.exe",

        # System-wide locations
        "C:\Program Files (x86)\Zoom\bin\Installer.exe",
        "C:\Program Files\Zoom\bin\Installer.exe",

        # Alternate installation paths (less common)
        "C:\ProgramData\Zoom\bin\Installer.exe",
        "C:\Program Files\Zoom Meetings\bin\Installer.exe",
        "C:\Program Files (x86)\Zoom Meetings\bin\Installer.exe",

        # MSI install locations (uninstaller executable)
        "C:\Windows\Installer\{ZoomMSIProductCode}\ZoomInstaller.exe"
    )

    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20)) | Out-Host

    $installerFound = $false
    foreach ($path in $zoomUninstallPaths) {
        if (Test-Path $path) {
            $installerFound = $true
            Write-Host "Found Zoom installer at: $path" -ForegroundColor Blue | Out-Host
            Write-Host "Uninstalling Zoom..." -ForegroundColor Blue | Out-Host
            Start-Process -FilePath $path -ArgumentList "/uninstall /silent" -Wait
            Write-Host "Zoom has been uninstalled!" -ForegroundColor Green | Out-Host
            break
        }
    }
    if (-not $installerFound) {
        $TryInstall = "Y"
        try {
            Write-Host "Zoom uninstaller not found in common locations`nTrying MSI uninstaller" -ForegroundColor Yellow | Out-Host
            UninstallZoomMSI($DomainName)
        }
        catch {
            Write-Host "Unable to uninstall Zoom - do so manually." -ForegroundColor Red
            $TryInstall = Read-Host "Zoom may not be installed to begin with - try to install? [Y/N]"
            # Wait for a valid response - use regex to validate input
            while ($TryInstall -notmatch '^[YyNn]$'){
                Write-Host "`n"
                Write-Host "Invalid input. Please enter Y or N." -ForegroundColor Red
                $TryInstall = Read-Host "Zoom may not be installed to begin with - try to install? [Y/N]"
            }
            if ($TryInstall -match '^[Nn]$'){
                Write-Host "Cancelling Zoom Upgrade." -ForegroundColor Yellow
                return
            }
        }
    }
    
    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20)) | Out-Host

    # Download and Install Zoom
    # Force TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $zoomInstaller = "C:\Users\$DomainName\Downloads\ZoomClient.msi"
    
    try {
        Write-Host "Zoom Downloading.." -ForegroundColor Blue | Out-Host
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile("https://zoom.us/client/latest/ZoomInstallerFull.msi", $zoomInstaller)
        Write-Host "Zoom has been downloaded.`n" -ForegroundColor Green

        if (Test-Path $zoomInstaller){
            Write-Host "Installing Zoom..." -ForegroundColor Blue
            Start-Process msiexec.exe -ArgumentList "/i `"$zoomInstaller`" /quiet /norestart" -Wait
            Write-Host "Zoom has been installed.`n" -ForegroundColor Green
            Write-Host "Creating Shortcut to Zoom" -ForegroundColor Blue

            $zoomAppPath = "C:\Program Files (x86)\Zoom\bin\Zoom.exe"
            $shortCutPath = "C:\Users\Public\Desktop\Zoom.lnk"

            if (Test-Path $zoomAppPath){
                $shell = New-Object -ComObject WScript.Shell
                $shorcut = $shell.CreateShortcut($shortCutPath)
                $shorcut.TargetPath = $zoomAppPath
                $shorcut.Save()
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell) | Out-Null
                Write-Host "Zoom shortcut has been created on the user's desktop." -ForegroundColor Green | Out-Host
            } else {
                Write-Host "Zoom executable was not found at $zoomAppPath" -ForegroundColor Red | Out-Host
            }

            Remove-Item $zoomInstaller -Force

            # Creating Shortcut
        } else {
            Write-Host "Zoom installer not found at: $zoomInstaller" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error downloading/installing Zoom: $($_.Exception.Message)" -ForegroundColor Red | Out-Host
    }
    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20)) | Out-Host  
}

function UpgradeZoom($HostName){
    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
    Write-Host "Starting Zoom Upgrade" | Out-Host

    if ((ValidateHostName $HostName)){
        try {
            Invoke-Command -ComputerName $HostName -ScriptBlock ${function:UpgradeZoomHelper}
        }
        catch {
            Write-Host "Failed to connect to $HostName or execute script: $_" -ForegroundColor Red
        }
    }
    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
    Write-Host "Zoom has been installed/upgraded.`nYou will need to sign in:`n1. Open Zoom`n2. Click 'Sign in'`n3. Click 'SSO'`n4. Type in 'UAMS'`n5. Press Continue`n6. Sign into browser and allow it to open Zoom.`nThis should automatically sign in with your UAMS Credentials." -ForegroundColor Cyan
    Write-Host "`nUAMS IT TSC`n(501)686-8555" -ForegroundColor Cyan
    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
}