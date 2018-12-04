# Jay-Tech

#
.Synopsis
   Removes the Deleted Accounts from the SMB Storage
.DESCRIPTION
   Removes the Deleted Accounts from the SMB Storage.
.EXAMPLE
   .\Remove-SMBSID.ps1
.EXAMPLE
   .\Remove-SMBSID.ps1 -Domain javedmohammed.lab -OutFilePath c:\MySMBReport.csv
.EXAMPLE
   .\Remove-SMBSID.ps1 -Domain javedmohammed.lab -Path 'C:\Script\Input.csv' -OutFilePath c:\MySMBReport.csv

#>
function Remove-ShareAccess {
    param(
        $Domain      = "javedmohammed",
        $Path        = 'C:\Script\Input.csv',
        $OutFilePath = 'C:\Script\SMB_Removal_Status_Report.csv'
    )

    #Declaration
    if (Test-Path -Path $Path) {
        $inputFile = Import-Csv -Path $Path
    }
    else {
        throw "The path to the input does not appear valid.  Aborting processing.  The error was $_"
    }
    $collectorArray = @()
    $result = @{}
    if (Test-Path -Path $OutFilePath) {
        Remove-Item $outFilePath -Force -ErrorAction SilentlyContinue
    }
    foreach ($item in $inputFile){
        $server = $item.name
        try {
            $fullServerName = ([System.Net.Dns]::GetHostEntry([string]"$server").HostName)
        }
        catch [System.Net.Sockets.SocketException] {
            $Exception = $_
            if ($Exception.Exception.Message -like "*The requested name is valid, but no data of the requested type was found*") {
                Write-Warning "Retrying DNS lookup for '$server' using the name '$(($server -split '\.')[0])'.  The error was: $($Error[0])"
                $fullServerName = ([System.Net.Dns]::GetHostEntry([string]"$(($server -split '\.')[0])").HostName)
                Write-Warning "Found DNS entry of '$fullServerName' for '$server' using the name '$(($server -split '\.')[0])'."
            }
            else {
                Write-Error "$($Error[0].Exception)"
                continue
            }
        }
        catch [System.Management.Automation.MethodInvocationException] {
            $Exception = $_
            if ($Exception.Exception.Message -like "*The requested name is valid, but no data of the requested type was found*") {
                Write-Warning "Retrying DNS lookup for '$server' using the name '$(($server -split '\.')[0])'.  The error was: $($Error[0])"
                $fullServerName = ([System.Net.Dns]::GetHostEntry([string]"$(($server -split '\.')[0])").HostName)
                Write-Warning "Found DNS entry of '$fullServerName' for '$server' using the name '$(($server -split '\.')[0])'."
            }
            else {
                Write-Error "$($Error[0].Exception)"
                continue
            }
        }
        $session = New-PSSession -ComputerName $fullServerName -UseSSL
        $SID = $item.user
        $shareFolder = $item.Share
        #alternate
        #get-adobject -Filter 'isdeleted -eq $true -and name -ne "Deleted Objects" -and objectSID -like "S-1-5-21-3715152346-304165531-80169466-1412"' -IncludeDeletedObjects -Properties samaccountname,displayname,objectsid
        $deletedUser = (Get-ADObject -Filter 'objectSID -like $sid' -IncludeDeletedObjects -Properties samaccountname,displayname,objectsid).samaccountname 
        [string]$fullUser = $Domain+$deletedUser


         try{
         <#
            Invoke-Command -Session $session -ScriptBlock {
                Revoke-SmbShareAccess -Name  $args[0] -AccountName  $args[1] -Confirm:$false
            }-ArgumentList  $shareFolder, $deletedUser -ea Stop | Out-Null
         #>
            $Proc = [ordered] @{
                    ComputerName = $item.name # or $fullServerName if you want FQDN
                    DeletedUser  = $fullUser
                    SID          = $sid
                    SharePath    = $shareFolder
                    Status       = "Access Removed"
                }
                $result= [pscustomobject]$Proc
        }
        catch{

            $Proc = [ordered] @{
                    ComputerName = $item.name # or $fullServerName if you want FQDN
                    DeletedUser  = $fullUser
                    SID          = $sid
                    SharePath    = $shareFolder
                    Status       = "Failed Removal"
                }
                $result= [pscustomobject]$Proc
        }
        finally{
            Remove-PSSession -Session $session
        }
       $collectorArray +=$result
    }

    $collectorArray | Export-csv $OutFilePath -Force -NoTypeInformation
    Write-Output "Script Executed Successfully"
    # Invoke-Expression $OutFilePath

} # function Remove-ShareAccess
