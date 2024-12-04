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

function CleanDevice() {
    [CmdletBinding()]
    param (
        [string[]] $HostNames
    )
    foreach ($HostName in $HostNames){
        if ((ValidateHostName $HostName)) {
            Invoke-Command -ComputerName $HostName -ScriptBlock {
                if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                    Write-Host "Please run this script with administrator privileges." -ForegroundColor Red
                    return
                }
            
                # BE SURE TO RUN THIS WITH FULL ADMIN RIGHTS - PREFERABLY WITH YOUR IT CREDS (OTHER USER)
                Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20)) -ForegroundColor Gray
                Write-Host "Starting Process to Delete Temporary Files on $using:HostName" -ForegroundColor Blue
                Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20)) -ForegroundColor Gray
                Write-Host "`n"
            
                # Display disk space info - before clearing data
                Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
                Write-Host "Getting Available Space.." -ForegroundColor Blue
                Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
                Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } |
                    Select-Object DeviceID,
                        @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
                        @{Name="TotalSize(GB)";Expression={[math]::Round($_.Size/1GB,2)}} | Out-Host  # Explicitly output to screen
            
                Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20)) | Out-Host
            
                # KILL VMWARE WITH EXTREME PREJUDICE (might notice a trend right about here)
                # Stop-VMwareProcesses
                # List of known VMware process names
                $vmwareProcesses = @(
                    "vmware-view",
                    "vmware-usbarbitrator64",
                    "vmware-usbarbitrator",
                    "vmware-horizon-client",
                    "vmware-horizon-url-handler",
                    "vmware-remotemks",
                    "vmware-view-usbfd",
                    "vmware-horizon-scanner",
                    "vmware-horizon-tsdr",
                    "vmware-tools*",
                    "VMwareHostd",
                    "VMwareService",
                    "VMwareTray",
                    "VMwareVDMDS",
                    "vmware-unity-helper",
                    "vmware-authd",
                    "vmnat",
                    "vmnetdhcp",
                    "vmusrv",
                    "vmware"
                )
                Write-Host "Starting aggressive VMware process termination...`n" -ForegroundColor Blue
            
                # First attempt: Standard process termination
                foreach ($procName in $vmwareProcesses) {
                    Get-Process -Name $procName -ErrorAction SilentlyContinue | ForEach-Object {
                        try {
                            $_ | Stop-Process -Force -ErrorAction SilentlyContinue
                            Write-Host "Stopped process: $($_.Name)" -ForegroundColor Green
                        } catch {
                            Write-Host "Failed to stop process $($_.Name) with standard method" -ForegroundColor Yellow
                        }
                    }
                }
            
                # Second attempt: Using taskkill for stubborn processes
                foreach ($procName in $vmwareProcesses) {
                    try {
                        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
                        $startInfo.FileName = "taskkill.exe"
                        $startInfo.Arguments = "/F /IM `"$procName.exe`""
                        $startInfo.UseShellExecute = $false
                        $startInfo.RedirectStandardOutput = $true
                        $startInfo.RedirectStandardError = $true
                        $startInfo.CreateNoWindow = $true
            
                        $process = New-Object System.Diagnostics.Process
                        $process.StartInfo = $startInfo
                        $process.Start() | Out-Null
                        $process.WaitForExit()
            
                        if ($process.ExitCode -eq 0) {
                            Write-Host "Forcefully terminated $procName using taskkill" -ForegroundColor Green
                        }
                    } catch {
                        Write-Host "Failed to terminate $procName with taskkill" -ForegroundColor Yellow
                    }
                }
            
                # Third attempt: Stop services - with hidden window (will not strobe light the user with cmd prompts)
                $vmwareServices = Get-Service -Name "VMware*" -ErrorAction SilentlyContinue
                foreach ($service in $vmwareServices) {
                    try {
                        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
                        $startInfo.FileName = "net.exe"
                        $startInfo.Arguments = "stop `"$($service.Name)`" /y"
                        $startInfo.UseShellExecute = $false
                        $startInfo.RedirectStandardOutput = $true
                        $startInfo.RedirectStandardError = $true
                        $startInfo.CreateNoWindow = $true
            
                        $process = New-Object System.Diagnostics.Process
                        $process.StartInfo = $startInfo
                        $process.Start() | Out-Null
                        $process.WaitForExit()
            
                        Write-Host "Stopped service: $($service.Name)" -ForegroundColor Green
                    } catch {
                        Write-Host "Failed to stop service $($service.Name)" -ForegroundColor Red
                    }
                }
            
                # Final check: Get any remaining VMware processes
                $remainingProcesses = $vmwareProcesses | ForEach-Object {
                    Get-Process -Name $_ -ErrorAction SilentlyContinue
                }
            
                if ($remainingProcesses) {
                    Write-Host "`nWARNING: Some VMware processes are still running:" -ForegroundColor Red
                    $remainingProcesses | ForEach-Object {
                        Write-Host "- $($_.Name) (PID: $($_.Id))" -ForegroundColor Red
                    }
                } else {
                    Write-Host "`nAll VMware processes have been terminated." -ForegroundColor Blue
                }
            
                # Add a small delay to ensure processes are fully terminated
                Start-Sleep -Seconds 2
            
                # Get a list of all users
                $usersPath = "C:\Users"
                $directories = Get-ChildItem -Path $usersPath | Where-Object { $_.PSIsContainer }
    
                Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
                
                Write-Host "Clearing Temporary Files.." -ForegroundColor Blue
                foreach ($directory in $directories) {
                    # Define the path to the Temp folder for each user
                    $tempPath = "$($directory.FullName)\AppData\Local\Temp"
            
                    if (Test-Path -Path $tempPath) {
                        # Kill any processes using files in this Temp folder
                        # Stop-ProcessesUsingTempFiles -tempPath $tempPath
            
                        # Get list of all processes
                        $processes = Get-Process | Where-Object {
                            # Only target processes that have file handles open in the Temp directory
                            $_.Path -like "$tempPath*"
                        }
            
                        foreach ($process in $processes) {
                            try {
                                Stop-Process -Id $process.Id -Force
                                Write-Host "Stopped process $($process.Name) (ID: $($process.Id)) holding files in $tempPath" -ForegroundColor Green
                            } catch {
                                Write-Host "Failed to stop process $($process.Name): $_" -ForegroundColor Red
                            }
                        }
            
                        # Remove all files and folders within the Temp directory
                        try {
                            Get-ChildItem -Path $tempPath -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                            Write-Host "Cleared Temp folder for user: $($directory.Name)" -ForegroundColor Green
                        } catch {
                            Write-Host "Failed to clear Temp folder for user: $($directory.Name) - $_" -ForegroundColor Red
                        }
                    } else {
                        Write-Host "Temp folder not found for user: $($directory.Name)" -ForegroundColor Yellow
                    }
                }
                Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
            
                Write-Host "Starting General Cleanup" -ForegroundColor Blue
                # Recursively remove general caches & dumps found on UAMS devices as a whole - Silently Deal with errors for these
                try {
                    Get-ChildItem -Path "C:\Windows\ccmcache" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction Continue
                    Write-Host "Cleared ccmcache" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to clear ccmcache" -ForegroundColor Red
                }
                
                try {
                    Get-ChildItem -Path "C:\Windows\SoftwareDistribution\Download" *.* -Recurse | Remove-Item -Recurse -Force -ErrorAction Continue
                    Write-Host "Cleared SoftwareDistribution Download folder" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to clear SoftwareDistribution Download folder" -ForegroundColor Red
                }
                
                try {
                    # Powershell and other open apps will be using these temp files actively - do not close them
                    Get-ChildItem -Path "C:\Windows\Temp" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    Write-Host "Cleared Windows Temp folder" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to clear Windows Temp folder" -ForegroundColor Red
                }
                
                try {
                    Get-ChildItem -Path "C:\ProgramData\VMware\logs" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction Continue
                    Write-Host "Cleared VMware logs" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to clear VMware logs" -ForegroundColor Red
                }
                
                try {
                    # This will trip an error if VMWare was just opened. The log file being used for today tends to remain opened by a background process.
                    # Not much of an issue, as this will only allow the one log file (for today) to remain in the folder/folders - use SilentlyContinue
                    Get-ChildItem -Path "C:\ProgramData\VMware\VDM\logs" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    Write-Host "Cleared VMware VDM logs" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to clear VMware VDM logs" -ForegroundColor Red
                }
                
                try {
                    Get-ChildItem -Path "C:\ProgramData\VMware\VDM\Dump" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction Continue
                    Write-Host "Cleared VMware VDM Dump folder" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to clear VMware VDM Dump folder" -ForegroundColor Red
                }
                
                try {
                    Get-ChildItem -Path "C:\ProgramData\VMware\VDM\Dumps" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction Continue
                    Write-Host "Cleared VMware VDM Dumps folder" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to clear VMware VDM Dumps folder" -ForegroundColor Red
                }
                
                try {
                    Get-ChildItem -Path "C:\Users\*\AppData\Local\CrashDumps" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction Continue
                    Write-Host "Cleared CrashDumps folder" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to clear CrashDumps folder" -ForegroundColor Red
                }
                
                try {
                    Get-ChildItem -Path "C:\Users\*\AppData\Local\VMware\VDM\logs" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction Continue
                    Write-Host "Cleared user VMware VDM logs" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to clear user VMware VDM logs" -ForegroundColor Red
                }
                
                try {
                    Get-ChildItem -Path "C:\Users\*\AppData\Local\VMware\VDM\Dumps" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction Continue
                    Write-Host "Cleared user VMware VDM Dumps" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to clear user VMware VDM Dumps" -ForegroundColor Red
                }
            
                # Clean the search database files
                Get-ChildItem -Path "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\windows.edb" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                Write-Host "Cleaned the search database files." -ForegroundColor Green
            
                # Stop the Windows Update service
                Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            
                # Remove Windows Update cache files
                $windowsUpdateCache = "C:\Windows\SoftwareDistribution\Download"
                if (Test-Path -Path $windowsUpdateCache) {
                    try {
                        Get-ChildItem -Path $windowsUpdateCache -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                        Write-Host "Cleared Windows Update cache." -ForegroundColor Green
                    } catch {
                        Write-Host "Failed to clear Windows Update cache: $_" -ForegroundColor Red
                    }
                } else {
                    Write-Host "Windows Update cache not found." -ForegroundColor Yellow
                }
            
                # Path to Prefetch folder
                $prefetchPath = "C:\Windows\Prefetch"
            
                if (Test-Path -Path $prefetchPath) {
                    try {
                        Get-ChildItem -Path $prefetchPath -File | Where-Object { $_.Name -like "*.pf" -and $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force -ErrorAction SilentlyContinue
                        Write-Host "Cleared old Prefetch files." -ForegroundColor Green
                    } catch {
                        Write-Host "Failed to clear Prefetch files: $_" -ForegroundColor Red
                    }
                } else {
                    Write-Host "Prefetch folder not found." -ForegroundColor Yellow
                }
        
                # Restart the Windows Update service
                try {
                    Start-Service -Name wuauserv -ErrorAction Continue -Verbose 
                    Write-Host "Started wuauserv service" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to Start-Service wuauserv: $_" -ForegroundColor Red
                }
                
                # Empty Recycle Bin
                try {
                    Clear-RecycleBin -Force -ErrorAction Continue -Verbose
                    Write-Host "Cleared Recycle Bin" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to empty recycle bin: $_" -ForegroundColor Red
                }
                
                # Display disk space info
                Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
                Write-Host "Process Complete - Getting Available Space.." -ForegroundColor Blue
                Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
                Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } |
                    Select-Object DeviceID,
                        @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
                        @{Name="TotalSize(GB)";Expression={[math]::Round($_.Size/1GB,2)}} | Out-Host  # Explicitly output to screen
            
            
                # Prompt the user for a reboot
                $response = Read-Host "Do you want to reboot the computer now? (y/n)"
            
                # Wait for a valid response - use regex to validate input
                while ($response -notmatch '^[YyNn]$'){
                    Write-Host "`n"
                    Write-Host "Invalid input. Please enter Y or N." -ForegroundColor Red
                    $response = Read-Host "Do you want to reboot the computer now? (y/n)"
                }
            
                if ($response -match '^[Yy]$') {
                    # user chose yes
                    Write-Host "Rebooting Computer in 5 seconds.." -ForegroundColor Yellow
                    shutdown /f /r /t 5
                } elseif ($response -match '^[Nn]$') {
                    # user chose not
                    Write-Host "Reboot canceled..process completed.`n" -ForegroundColor Green
                }
            }
        }    
    }    
}