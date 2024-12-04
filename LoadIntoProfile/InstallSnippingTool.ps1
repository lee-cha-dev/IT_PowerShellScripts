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

function InstallSnippingTool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)]
        [string[]]$HostNames
    )

    $InstallerPath = "\\DIT0317\C`$\Users\charleskristopher\Downloads\Snipping Tool Installer.exe"

    foreach ($pc in $HostNames) {
        try {
            if ((ValidateHostName $pc)) {
                # Invoke command on remote system
                Invoke-Command -ComputerName $pc -ScriptBlock {
                    param ($installerPath)
                    Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
                    try {
                        Write-Host "Launching Snipping Tool installer on $env:COMPUTERNAME..." -ForegroundColor Blue
                        
                        # Launch the installer
                        Start-Process -FilePath $installerPath -ArgumentList "/silent" -Wait

                        Write-Host "Snipping Tool installation completed on $env:COMPUTERNAME." -ForegroundColor Green
                    }
                    catch {
                        Write-Host "Error while processing on $env:COMPUTERNAME: $_" -ForegroundColor Red
                    }
                } -ArgumentList $InstallerPath
            }
        }
        catch {
            Write-Host "Failed to validate or execute command on $pc : $_" -ForegroundColor Red
        }
        Write-Host ("-" * ([math]::Floor($Host.UI.RawUI.WindowSize.Width/5) * 2 + 20))
    }
}
