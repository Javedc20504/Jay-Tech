$ServiceName = 'bits' 
$arrService = Get-Service -Name $ServiceName
$Logtime = Get-Date -Format “MM-dd-yyyy-hh:mm:ss” 
while ($arrService.Status -ne 'Running') {
Start-Service $ServiceName -ErrorAction SilentlyContinue
Write-Output " $Logtime :  $servicename was stopped and is starting now"   | Out-File C:\Test\ServiceStatus.txt -Append
Write-Output " Service starting" | Out-File C:\Test\ServiceStatus.txt -Append
Start-Sleep -seconds 10
$arrService.Refresh()
if ($arrService.Status -eq 'Running')
{
rite-Output "$logtime : $servicename Service is Running" | Out-File C:\Test\ServiceStatus.txt -Append
} 
}
