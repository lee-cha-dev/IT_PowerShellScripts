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

Import-Module ActiveDirectory

function UnlockAccount(){
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$DomainName
    )

    $DomainName = $DomainName.ToLower()

    try {
        $user = Get-AdUser -Identity $DomainName -Properties LockedOut

        # check if account exists
        if ($null -eq $user){
            Write-Host "User account '$user' was not found in Active Directory" -ForegroundColor Red
            return
        }

        # check if account locked
        if (-not $user.LockedOut){
            Write-Host "Account '$DomainName' is not locked." -ForegroundColor Yellow
            return
        }

        # unlock the account
        Unlock-ADAccount -Identity $DomainName
        Write-Host "Successfully unlocked account for '$DomainName'" -ForegroundColor Green
    } catch {
        Write-Host "Failed to unlock account for '$DomainName': $_" -ForegroundColor Red
    }
}