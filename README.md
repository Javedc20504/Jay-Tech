$logPath = "c:\test\fileTransferLog.txt"
$fileTransferPath = "C:\Test\files"
$expiredFilePath = "c:\test\Expired Files\*"
#07.06.18 - changed $expireInterval from '15' to '60'; INC0170666\CHG0042621

## $moveInterval = "15"
$expireInterval = "60"

do{
    $files = Get-ChildItem -Path $fileTransferPath -Recurse
    foreach ($file in $files){
        $fileAge = ((Get-Date) - ($file.CreationTime)).TotalMinutes
        
        if ($fileAge -ge $expireInterval) {

           Try{
                $file | Remove-Item -Force -Confirm:$false -Recurse -ErrorAction Stop
                Write-Output "$(Get-Date) -- Deleted  -- File Path: `"$($file.fullname)`" -- Size: $([math]::round(($file.Length / 1KB),2))KB" | Out-File $logPath -Append
           }
           Catch{
                Write-Output "$(Get-Date) -- Error $($Error[0].Exception) -- File Path: `"$($file.fullname)`" -- Size: $([math]::round(($file.Length / 1KB),2))KB" | Out-File $logPath -Append
           }
        }
    }
    Start-Sleep -Seconds 60
}
While ($true)
