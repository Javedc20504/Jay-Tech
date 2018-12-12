#Generate Service Status report and start a serivce if it is stopped
$Logtime = Get-Date -Format “MM-dd-yyyy-hh:mm:ss.fff”
$Logfile= Get-Date -Format "MM-dd-yyyy-hh-mm-ss"
$sr = "$Logfile-Log.csv"
$sl = "$Logfile-ServiceReport.csv"
$s = @('bits','winrm','wuauserv','dosvc','SCardSvr','VaultSVC','SysMain','SENS','SamSs')
Write-Output "SNo,Name,Status,DisplayName" | out-file .\$sl -Append
for($i=1; $i -le  $s.Count; $i++)
{
$m=get-service -name $s[$i-1]
$ServiceName=$m.Name
$i,$m.Name,$m.Status,$m.DisplayName -join ','  | out-file .\$sl -Append
}


Write-Output "SNo,DateTime,Name,Status,DisplayName,CustomEvent" | out-file .\$sr -Append
for($i=1; $i -le  $s.Count; $i++)
{
$Logtime = Get-Date -Format “MM-dd-yyyy-hh:mm:ss.fff”
$m=get-service -name $s[$i-1]
$ServiceName=$m.Name
$op=$i,$Logtime,$m.Name,$m.Status,$m.DisplayName -join ',' 
write-host $op
write-output $op | out-file .\$sr -Append
$at=0
while ($m.Status -ne 'Running') 
{ 
$at++
$Logtime = Get-Date -Format “MM-dd-yyyy-hh:mm:ss.fff”
$op = $i,$Logtime,$m.Name,$m.Status,$m.DisplayName,"Service Stopped Trying to Start the Service Now Attempt $at" -join ','
write-host $op
write-output $op | out-file .\$sr -Append
Start-Service $m -ErrorAction SilentlyContinue
Start-Sleep -seconds 10 
$m.Refresh() 
if ($m.Status -eq 'Running') 
{ 
 $Logtime = Get-Date -Format “MM-dd-yyyy-hh:mm:ss.fff”
 $op = $i,$Logtime,$m.Name,$m.Status,$m.DisplayName,"Service Started and Running Now" -join ','
 write-host $op
 write-output $op | out-file .\$sr -Append
} 
else
{
$Logtime = Get-Date -Format “MM-dd-yyyy-hh:mm:ss.fff”
 $op = $i,$Logtime,$m.Name,$m.Status,$m.DisplayName,"Service not Started Attempt $at" -join ','
 write-host $op
 write-output $op | out-file .\$sr -Append
}
if ($at -eq 5)
{
$Logtime = Get-Date -Format “MM-dd-yyyy-hh:mm:ss.fff”
 $op = $i,$Logtime,$m.Name,$m.Status,$m.DisplayName,"Service Not Started Even after $at attempts" -join ','
 write-host $op
 write-output $op | out-file .\$sr -Append
break;
}
}
}


