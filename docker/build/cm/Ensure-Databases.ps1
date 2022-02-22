$sqlInstanceName = "MSSQLLocalDB"
$sqlShareName = "SC"
$sqlServer = "(LocalDB)\.\$sqlShareName"
$sqlLogin = "IIS APPPOOL\DefaultAppPool"

# ensure localdb is ready
sqllocaldb.exe create $sqlInstanceName
sqllocaldb.exe share $sqlInstanceName $sqlShareName
sqllocaldb.exe start $sqlInstanceName

# deploy any missing databases
$existingDatabases = (sqlcmd.exe -S $sqlServer -Q "SET NOCOUNT ON; SELECT name FROM sys.databases" -h -1 -W)
$expectedDatabases = Get-ChildItem -Path "C:\mssql-init\resources" -Filter "*.dacpac"
$missingDatabases = $expectedDatabases | Where-Object { !$existingDatabases.Contains($_.BaseName) }

if ($missingDatabases.Count -gt 0)
{
    $missingDatabases | ForEach-Object {
        sqlpackage.exe /a:Publish /sf:"$($_.FullName)" /p:AllowIncompatiblePlatform=True /tdn:"$($_.BaseName)" /tsn:$sqlServer

        $LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw ("Error while deploying '{0}'." -f $_.FullName) }
    }
}
else
{
    Write-Host "Existing Sitecore databases present, skipping database deployment..."
}

# deploy any missing SQL logins
$deploySqlLogin = (sqlcmd.exe -S $sqlServer -Q "SELECT COUNT(*) FROM sys.server_principals WHERE name = '$sqlLogin';" -h -1 -W | Select-Object -First 1) -eq "0"

if ($deploySqlLogin)
{
    sqlcmd.exe -S $sqlServer -Q "CREATE LOGIN [$sqlLogin] FROM Windows; EXEC sp_addsrvrolemember '$sqlLogin', sysadmin;"
}
else
{
    Write-Host "Existing SQL login present, skipping sql login deployment..."
}
