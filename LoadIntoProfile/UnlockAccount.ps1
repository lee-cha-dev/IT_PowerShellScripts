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

        # Verify the account was unlocked
        $verifyUser = Get-ADUser -Identity -Properties LockedOut
        if (-not $verifyUser.LockedOut){
            Write-Host "Successfully unlocked account for '$DomainName'" -ForegroundColor Green
            return
        }
        Write-Host "Failed to unlock account for '$DomainName'" -ForegroundColor Red
    } catch {
        Write-Host "Failed to unlock account for '$DomainName': $_" -ForegroundColor Red
    }
}