function CopyFile {
    param (
        [string]$HostName,
        [string]$DomainName,
        [string]$FileName,
        [string]$dest = "\\$HostName\c$\Users\$DomainName\Desktop"
    )
    
    if ((ValidateHostName($HostName))){
        # create file path based on current dir
        $currentPath = (Get-Location).Path
        $file = Join-Path -Path $currentPath -ChildPath $FileName

        # check for dest & file paths
        if (!(Test-Path -Path $file)){
            Write-Host "File (to be moved) path to does not exist." -ForegroundColor Red
            return
        }
        if (!(Test-Path -Path $dest)){
            Write-Host "Destination path to does not exist." -ForegroundColor Red
            return
        }

        # try to move the file to the path
        try {
            Copy-Item -Path $file -Destination $dest -ErrorAction Stop
            Write-Host "Moved '$file' to '$dest'`n" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to move '$file' to '$dest': $_`n" -ForegroundColor Red
        }
    }   
}