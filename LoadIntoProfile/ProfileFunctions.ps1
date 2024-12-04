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

function ValidateHostName($HostName){
    # $hostnamePattern = '^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?$'

    if (-not $HostName -or -not (Test-Connection -ComputerName $HostName -Count 1 -Quiet)){
        Write-Host "Invalid or unreachable hostname: $HostName" -ForegroundColor Red
        return $false
    }
    return $true
}

function list {
    Downloads
    Write-Host "Available functions/tools:`n" -ForegroundColor Cyan
    ListCommands
    Installs
}

# Function to Write Color-Coded Messages
function Write-ColorMessage {
    param(
        [string]$Message,
        [string]$Status
    )
    
    switch ($Status) {
        'error'   { Write-Host $Message -ForegroundColor Red }
        'success' { Write-Host $Message -ForegroundColor Green }
        'warning' { Write-Host $Message -ForegroundColor Yellow }
    }
}

function Get-LoggedIn() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [string[]]$ComputerName
    )
    foreach ($pc in $ComputerName){
        if ((ValidateHostName $pc)){
            $logged_in = (Get-WmiObject win32_computersystem -COMPUTER $pc).username
            $name = $logged_in.split("\")[1]
            "{0}: {1}" -f $pc,$name
        }        
    }
}

# Get disk space
function DiskSpace(){
    # Create get hard disk space
    Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } |
    Select-Object DeviceID,
        @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
        @{Name="TotalSize(GB)";Expression={[math]::Round($_.Size/1GB,2)}} | Out-Host  # Explicitly output to screen
}

function Get-DiskSpace(){
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [string[]]$HostNames
    )
    foreach ($pc in $HostNames){
        if ((ValidateHostName $pc)){
            # Create get hard disk space
            Invoke-Command -ComputerName $pc -ScriptBlock ${function:Diskspace}
        }
    }
}

function Get-Uptime {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [string[]]$ComputerName
    )
    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
    Write-Host "`nGet Uptime Details For All Computers..`n" -ForegroundColor Blue
    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
    foreach ($pc in $ComputerName) {
        try {
            if ((ValidateHostName $pc)){
                $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $pc
                $uptime = (Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime)
                
                [PSCustomObject]@{
                    'ComputerName' = $pc
                    'UptimeDays' = $uptime.Days
                    'UptimeHours' = $uptime.Hours
                    'UptimeMinutes' = $uptime.Minutes
                    'UptimeSeconds' = $uptime.Seconds
                }
                Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20)) | Out-Host  # Pipe to Out-Host to ensure the ---- occur afer the uptime data
            }
        }
        catch {
            Write-Host "Failed to get uptime for $pc : $_" -ForegroundColor Red
        }
    }
    Write-Host "`nGet-Uptime has completed.`n" -ForegroundColor Blue
    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
}

function AdminRights($HostName, $DomainName){
    if ((ValidateHostName $HostName)){
        Invoke-Command -ComputerName $HostName -ScriptBlock ${function:AdminRightsHelper} -ArgumentList $HostName, $DomainName
    }
}

function AdminRightsHelper(){
    [CmdletBinding()]
    param(
        [string]$HostName,
        [string]$DomainName
    )

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Please run this script with administrator privileges." -ForegroundColor Red
        return
    }

    if ([string]::IsNullOrEmpty($HostName) -or [string]::IsNullOrEmpty($DomainName)){
        Write-Host "Host name and domain name required." -ForegroundColor Red | Out-Host
        return 
    }

    try {    # check if user exists
        $userCheck = NET USER $DomainName /DOMAIN 2>&1
        if ($LASTEXITCODE -ne 0){
            Write-Host "UserCheck: $userCheck`nUser $DomainName not found in domain $HostName" -ForegroundColor Red
            return
        }

        # Add user to admin group using NET LOCALGROUP
        NET LOCALGROUP "Administrators" $DomainName /ADD
        if ($LASTEXITCODE -eq 0){
            # Verify the addition
            $groupMembers = NET LOCALGROUP Administrators
            if ($groupMembers -like "*$DomainName*"){
                Write-Host "Successfully added $DomainName to Administrators group." -ForegroundColor Green
            } else {
                Write-Host "User was added but verification failed. Please check manually." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Failed to add user to the admin group." -ForegroundColor Red
        }
    } catch {
        Write-Host "Error occurred: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function rebootdevice($HostName){
    if ((ValidateHostName $HostName)){
        shutdown /m \\$HostName /r /f /t 0
    }    
}   

function ListCommands(){
    Write-Host "InstallSnippingTool -HostName`nUpdgradeZoom -HostName`nGet-Uptime`nGet-DiskSpace -HostName`nGet-LoggedIn`nrebootdevice -HostName`nAdminRights -HostName -DomainName`nCleanDevice -HostName`nGet-Hardware -HostName`nUnlockAccount -DomainName`nCopyFile -HostName -DomainName -FileName`n"
}