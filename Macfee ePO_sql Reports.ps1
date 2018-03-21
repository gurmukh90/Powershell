################################################################
#################### McAfee ePO database #######################
################################################################
if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
{ # Powershell script
	$presentpath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
else
{ # PS2EXE compiled script
	$presentpath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
}
$sqlserverinstance = "192.168.1.68\eposerver"
$username = "etaudit"
$credential = Get-Credential -UserName $username -Message "Enter credential for Eposerver database"
$database = (Invoke-Sqlcmd -ServerInstance $sqlserverinstance -Query "select Name from sys.databases" -Username $credential.UserName -Password ($credential.GetNetworkCredential()).Password | Where-Object {@("master","tempdb","model","msdb") -notcontains $_.name}).name
while($true){
if(!(Test-Path $presentpath\McAfeeReports)){
New-Item $presentpath\McAfeeReports -ItemType Directory
}
if(Test-Path $presentpath\Support\lastpick.xml){
$id = Import-Clixml $presentpath\Support\lastpick.xml
$value = "autoid > $($id.autoid) AND"
} else{
$id = $null
$value = $null
}
$query = "Select al.UserName,
                 al.Priority,
                 al.CmdName,
                 al.Message,
                 al.Success,
                 al.StartTime,
                 al.EndTime,
                 al.RemoteAddress,
                 td.Name as TenantName 
          from OrionAuditLogMT as al,OrionTenant as td 
          WHERE $value 
          al.Tenantid = td.Tenantid"
Invoke-Sqlcmd -ServerInstance $sqlserverinstance -Database $database -Query $query -Username $credential.UserName -Password ($credential.GetNetworkCredential()).Password | Select-Object -Property UserName,
@{N='Priority';E={switch ($_.Priority) { 1 {"High"}; 2 {"medium"}; 3 {"low"}}}},CmdName,Message,Success,StartTime,EndTime,RemoteAddress,TenantName | Export-Csv -Path $presentpath\McAfeeReports\AuditLog.csv -NoTypeInformation -Append
Invoke-Sqlcmd -ServerInstance $sqlserverinstance -Database $database -Query "select Top(1) Autoid from orionAuditLogMT Order by AutoID Desc" -Username $credential.UserName -Password ($credential.GetNetworkCredential()).Password | %{ 
#$_.autoid
if($id){
if($_.autoid -gt $id.Autoid){
$_ | Export-Clixml $presentpath\Support\LastPick.xml
}elseif($_.autoid -lt $id.Autoid){
Remove-Item $presentpath\Support\LastPick.xml
}
}
else{
$_ | Export-Clixml $presentpath\Support\LastPick.xml
}
}
if(Test-Path $presentpath\Support\lastpickte.xml){
$idte = Import-Clixml $presentpath\Support\lastpickte.xml
$valuete = "WHERE autoid > $($idte.autoid)"
} else{
$idte = $null
$valuete = $null
}
$queryTE = "Select * 
          from EPOEvents
          $valuete"
Invoke-Sqlcmd -ServerInstance $sqlserverinstance -Database $database -Query $queryte -Username $credential.UserName -Password ($credential.GetNetworkCredential()).Password | Export-Csv -Path $presentpath\McAfeeReports\ThreatLog.csv -NoTypeInformation -Append
Invoke-Sqlcmd -ServerInstance $sqlserverinstance -Database $database -Query "select Top(1) Autoid from EPOEvents Order by AutoID Desc" -Username $credential.UserName -Password ($credential.GetNetworkCredential()).Password | %{ 
#$_.autoid
if($idte){
if($_.autoid -gt $idte.Autoid){
$_ | Export-Clixml $presentpath\Support\LastPickte.xml
}elseif($_.autoid -lt $idte.Autoid){
Remove-Item $presentpath\Support\LastPickte.xml
}
}
else{
$_ | Export-Clixml $presentpath\Support\LastPickte.xml
}
}
}