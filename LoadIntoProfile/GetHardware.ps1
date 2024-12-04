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


function Get-Hardware([string]$HostName){
    # [CmdletBinding]
    # param (
    #     [string]$HostName
    # )
    if((ValidateHostName($HostName))){
        Invoke-Command -ComputerName $Hostname -ScriptBlock {
            # Example usage in PowerShell:
            $BIOSRegistry = Get-ItemProperty -Path 'HKLM:\HARDWARE\DESCRIPTION\System\BIOS'

            # BiosMajorRelease       : Major version of the BIOS firmware.
            # BiosMinorRelease       : Minor version of the BIOS firmware.
            # ECFirmwareMajorRelease : Major version of the embedded controller firmware.
            # ECFirmwareMinorRelease : Minor version of the embedded controller firmware.
            # BaseBoardManufacturer  : The manufacturer of the motherboard (e.g., Hewlett-Packard).
            # BaseBoardProduct       : The product or model number of the motherboard.
            # BaseBoardVersion       : The version of the motherboard.
            # BIOSReleaseDate        : The release date of the BIOS firmware.
            # BIOSVendor             : The vendor or manufacturer of the BIOS (often matches BaseBoardManufacturer).
            # BIOSVersion            : The version identifier for the BIOS firmware.
            # SystemFamily           : Family or classification of the system (may include specific model identifiers).
            # SystemManufacturer     : The manufacturer of the system (often matches BaseBoardManufacturer).
            # SystemProductName      : The model or product name of the system (e.g., HP ProBook 450 G2).
            # SystemSKU              : The stock-keeping unit, identifying the specific system configuration.
            # SystemVersion          : Version identifier for the system.

            $Output = [PSCustomObject]@{
                BaseBoardManufacturer = $BIOSRegistry.BaseBoardManufacturer
                BaseBoardProduct      = $BIOSRegistry.BaseBoardProduct
                SystemFamily          = $BIOSRegistry.SystemFamily
                SystemManufacturer    = $BIOSRegistry.SystemManufacturer
                SystemProductName     = $BIOSRegistry.SystemProductName
            }


            Get-CimInstance -ClassName Win32_BIOS

            # Useful properties:
            # Manufacturer - BIOS manufacturer
            # Version - BIOS version
            # ReleaseDate - Date of BIOS release
            # SerialNumber - BIOS serial number


            Get-CimInstance -ClassName Win32_BaseBoard

            # Useful Properties:
            # Manufacturer - The manufacturer of the motherboard (e.g.,Dell, ASUS).
            # Product - The model or product name of the motherboard.
            # SerialNumber - The serial number of the motherboard, which can be useful for inventory tracking.
            # Version - The version of the motherboard.
            # Name - The name of the baseboard, though it's often generic.
            # Status - Operational status of the motherboard; usually OK or another state if there is a problem.
            # PoweredOn - Indicates if the baseboard is currently powered on (though this property may not be populated on all systems).

            Get-CimInstance -ClassName Win32_Processor

            # Useful properties:
            # Name - Processor name
            # NumberOfCores - Number of cores
            # NumberOfLogicalProcessors - Logical processors (threads)
            # MaxClockSpeed - Max clock speed in MHz
            # ProcessorId - Unique processor ID

            Get-CimInstance -ClassName Win32_DiskDrive

            # Useful properties:
            # Model - Disk model
            # Size - Size of disk in bytes
            # SerialNumber - Disk serial number
            # MediaType - Media type (e.g., SSD or HDD)

            Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

            # Useful properties:
            # Description - Network adapter name
            # MACAddress - MAC address
            # IPAddress - Array of IP addresses
            # DefaultIPGateway - Default gateway
            # DNSServerSearchOrder - DNS servers

            Get-CimInstance -ClassName Win32_LogicalDisk

            # Useful properties:
            # DeviceID - Drive letter (e.g.,C:)
            # DriveType - Type of drive (e.g.,fixed, network, CD-ROM)
            # FileSystem - File system type (e.g.,NTFS)
            # FreeSpace - Free space in bytes
            # Size - Total size in bytes

            # Laptops
            Get-CimInstance -ClassName Win32_Battery
            # Useful Properties:
            # BatteryStatus - Indicates the current battery status:
            # 1 = Discharging
            # 2 = AC power, not charging
            # 3 = Fully charged
            # 4 = Low
            # 5 = Critical
            # 6 = Charging
            # 7 = Charging and high
            # 8 = Charging and low
            # 9 = Charging and critical
            # 10 = Undefined
            # 11 = Partially charged
            # EstimatedChargeRemaining - Remaining battery charge as a percentage.
            # EstimatedRunTime - Estimated remaining runtime in minutes (if discharging).
            # ExpectedBatteryLife - Estimated total battery life in minutes.
            # ExpectedLife - Expected battery life span, usually in years.
            # TimeOnBattery - Time, in seconds, since the last switch to battery power.
            # DesignCapacity - Original capacity of the battery in mWh.
            # FullChargeCapacity - Current full charge capacity in mWh.
            # Chemistry - Battery chemistry (e.g., Lithium-Ion, Nickel-Cadmium).

            Get-CimInstance -ClassName Win32_ComputerSystem
            # Useful properties:
            # Manufacturer - Manufacturer of the system (e.g.,Dell, HP)
            # Model - Model of the system
            # SystemType - System type (e.g.,x64-based PC)
            # TotalPhysicalMemory - Total RAM in bytes

            Get-CimInstance -ClassName Win32_OperatingSystem
            # Useful properties:
            # Caption - OS name (e.g., Windows 10 Pro)
            # Version - Version number (e.g., 10.0.19042)
            # BuildNumber - Build number
            # OSArchitecture - Architecture (e.g., 64-bit)
            # InstallDate - OS installation date
            # LastBootUpTime - Last reboot time
            # SerialNumber - OS serial number

            # https://github.com/Trael-Kun/Powershell/blob/a3158f47be8f56f173d79ec5da757089a3920626/BIOS_Dell_UpdateBios.ps1
            ###################################################################################################
            # TASK - GET BATTERY EXISTANCE AND AMOUNT OF BATTERY CHARGE REMAINING
            ###################################################################################################
            [int]$HasBattery = (Get-CimInstance -ClassName Win32_Battery).Availability
            [int]$ChargeRemaining = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining

            ###################################################################################################
            # TASK - IF THE BATTERY IS LESS THAN 90% CHARGED, WAIT UNTIL IT IS
            ###################################################################################################
            if ($HasBattery -ne 0 -AND $ChargeRemaining -le 60)
            {
                DO
                {
                    Start-Sleep -s 20
                    [int]$ChargeRemaining = (Get-CimInstance -ClassName Win32_Battery).EstimatedChargeRemaining

                    Format-Form

                } Until ($ChargeRemaining -ge 60)
            }
        }
    }
}