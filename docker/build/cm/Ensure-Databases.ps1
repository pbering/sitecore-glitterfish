$sqlInstanceName = "MSSQLLocalDB"
$sqlShareName = "SC"

sqllocaldb.exe create $sqlInstanceName
sqllocaldb.exe share $sqlInstanceName $sqlShareName
sqllocaldb.exe start $sqlInstanceName

$sqlServer = "(LocalDB)\.\$sqlShareName"

sqlcmd.exe -S $sqlServer -Q "CREATE LOGIN [IIS APPPOOL\DefaultAppPool] FROM Windows; EXEC sp_addsrvrolemember 'IIS APPPOOL\DefaultAppPool', sysadmin;"
sqlpackage.exe /a:Publish /sf:C:\mssql-init\resources\Sitecore.Core.dacpac /p:AllowIncompatiblePlatform=True /tdn:Sitecore.Core /tsn:$sqlServer
sqlpackage.exe /a:Publish /sf:C:\mssql-init\resources\Sitecore.Master.dacpac /p:AllowIncompatiblePlatform=True /tdn:Sitecore.Master /tsn:$sqlServer
sqlpackage.exe /a:Publish /sf:C:\mssql-init\resources\Sitecore.Web.dacpac /p:AllowIncompatiblePlatform=True /tdn:Sitecore.Web /tsn:$sqlServer
sqlpackage.exe /a:Publish /sf:C:\mssql-init\resources\Sitecore.ExperienceForms.dacpac /p:AllowIncompatiblePlatform=True /tdn:Sitecore.ExperienceForms /tsn:$sqlServer
