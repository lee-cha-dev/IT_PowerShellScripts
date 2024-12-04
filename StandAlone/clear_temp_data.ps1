# Primary function to clear out temporary data common on Win10/11
function ClearTempData(){
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Log-Message "Please run this script with administrator privileges." -ForegroundColor Red
        return
    }

    # BE SURE TO RUN THIS WITH FULL ADMIN RIGHTS - PREFERABLY WITH YOUR IT CREDS (OTHER USER)
    Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
    Write-Host "Starting Process to Delete Temporary Files." -ForegroundColor Blue
    Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
    Write-Host "`n"

    # Display disk space info - before clearing data
    Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
    Write-Host "Getting Available Space.." -ForegroundColor Blue
    Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
    Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } |
        Select-Object DeviceID,
            @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
            @{Name="TotalSize(GB)";Expression={[math]::Round($_.Size/1GB,2)}} | Out-Host  # Explicitly output to screen

    Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width) | Out-Host
    Write-Host ("`n") | Out-Host

    # KILL VMWARE WITH EXTREME PREJUDICE (might notice a trend right about here)
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

    Write-Host "Starting aggressive VMware process termination..." -ForegroundColor Blue

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
        Write-Host "All VMware processes have been terminated.`n" -ForegroundColor Blue
    }

    # Add a small delay to ensure processes are fully terminated
    Start-Sleep -Seconds 2

    # Get a list of all users
    $usersPath = "C:\Users"
    $directories = Get-ChildItem -Path $usersPath | Where-Object { $_.PSIsContainer }

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

    # Recursively remove general caches & dumps found on UAMS devices as a whole - Silently Deal with errors for these
    Get-ChildItem -Path "C:\Windows\ccmcache" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem -Path "C:\Windows\SoftwareDistribution\Download" *.* -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path "C:\Windows\Temp" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem -Path "C:\ProgramData\VMware\logs" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem -Path "C:\ProgramData\VMware\VDM\logs" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem -Path "C:\ProgramData\VMware\VDM\Dump" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem -Path "C:\ProgramData\VMware\VDM\Dumps" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem -Path "C:\Users\*\AppData\Local\CrashDumps" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem -Path "C:\Users\*\AppData\Local\VMware\VDM\logs" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Get-ChildItem -Path "C:\Users\*\AppData\Local\VMware\VDM\Dumps" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

    Write-Host "`nCleared General Caches & Dumps Found On UAMS Devices" -ForegroundColor Green

    # Clean the search database files
    Get-ChildItem -Path "C:\ProgramData\Microsoft\Search\Data\Applications\Windows\windows.edb" *.* -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "Cleaned the search database files." -ForegroundColor Green

    Write-Host "`n"
    Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
    Write-Host "`n"
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

    # Remove Delivery Optimization Cache
    $deliveryOptCache = "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache"
    if (Test-Path -Path $deliveryOptCache) {
        try {
            Start-Process -Wait -FilePath cleanmgr -ArgumentList "/sagerun:99"
            Write-Host "Cleared Delivery Optimization Cache.`n" -ForegroundColor Green
        } catch {
            Write-Host "Failed to clear Delivery Optimization Cache: $_`n" -ForegroundColor Red
        }
    } else {
        Write-Host "Delivery Optimization Cache not found.`n" -ForegroundColor Yellow
    }

    # Restart the Windows Update service
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue

    # Empty Recycle Bin
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue

    # Run Windows Disk Cleanup utility
    Start-Process -Wait -FilePath cleanmgr -ArgumentList "/sagerun:99"


    # Display disk space info
    Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
    Write-Host "Process Complete - Getting Available Space.." -ForegroundColor Blue
    Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
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

ClearTempData