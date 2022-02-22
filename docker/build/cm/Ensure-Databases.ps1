$sqlInstanceName = "Sitecore"
$sqlShareName = "SC_DB"

sqllocaldb.exe create $sqlInstanceName
sqllocaldb.exe share $sqlInstanceName $sqlShareName
sqllocaldb.exe start $sqlInstanceName

$sqlServer = "(LocalDB)\.\$sqlShareName"

sqlcmd.exe -S $sqlServer -Q "create login [IIS APPPOOL\DefaultAppPool] from windows; exec sp_addsrvrolemember 'IIS APPPOOL\DefaultAppPool', sysadmin;"
sqlpackage.exe /a:Publish /sf:C:\mssql-init\resources\Sitecore.Core.dacpac /p:AllowIncompatiblePlatform=True /tdn:Sitecore.Core /tsn:$sqlServer
sqlpackage.exe /a:Publish /sf:C:\mssql-init\resources\Sitecore.Master.dacpac /p:AllowIncompatiblePlatform=True /tdn:Sitecore.Master /tsn:$sqlServer
sqlpackage.exe /a:Publish /sf:C:\mssql-init\resources\Sitecore.Web.dacpac /p:AllowIncompatiblePlatform=True /tdn:Sitecore.Web /tsn:$sqlServer
sqlpackage.exe /a:Publish /sf:C:\mssql-init\resources\Sitecore.ExperienceForms.dacpac /p:AllowIncompatiblePlatform=True /tdn:Sitecore.ExperienceForms /tsn:$sqlServer
