$sqlInstanceName = "MSSQLLocalDB"
$sqlShareName = "SC"
$sqlServer = "(LocalDB)\.\$sqlShareName"
$sqlLogin = "IIS APPPOOL\DefaultAppPool"
$sqlDataRoot = "$env:USERPROFILE\AppData\Local\Microsoft\Microsoft SQL Server Local DB\Instances\$sqlInstanceName"

# ensure localdb is ready
$localDbState = (sqllocaldb.exe info $sqlInstanceName | Select-String "State:")

if ($null -eq $localDbState)
{
    sqllocaldb.exe share $sqlInstanceName $sqlShareName
}

if ($null -ne $localDbState -and $localDbState -like "*stopped")
{
    sqllocaldb.exe start $sqlInstanceName
}

Write-Host "### LocalDB ready."

# ensure databases ready
$existingDatabases = (sqlcmd.exe -S $sqlServer -Q "SET NOCOUNT ON; SELECT name FROM sys.databases" -h -1 -W)
$expectedDatabases = Get-ChildItem -Path "C:\mssql-init\resources" -Filter "*.dacpac"
$missingDatabases = $expectedDatabases | Where-Object { !$existingDatabases.Contains($_.BaseName) }

if ($missingDatabases.Count -gt 0)
{
    $missingDatabases | ForEach-Object {

        $databaseName = $_.BaseName
        $databaseDataFilePath = "$sqlDataRoot\$databaseName`_Primary.mdf"
        $databaseLogFilePath = "$sqlDataRoot\$databaseName`_Primary.ldf"
        $attachDatabase = (Test-Path $databaseDataFilePath) -and (Test-Path $databaseLogFilePath)

        if ($attachDatabase)
        {
            Write-Host "### Attaching database '$databaseName'."

            sqlcmd.exe -S $sqlServer -Q "CREATE DATABASE [$databaseName] ON (FILENAME = '$databaseDataFilePath'), (FILENAME = '$databaseLogFilePath') FOR ATTACH;"
        }
        else
        {
            Write-Host "### Deploying dacpac as '$databaseName'."

            sqlpackage.exe /a:Publish /sf:$_.FullName /p:AllowIncompatiblePlatform=True /tdn:$databaseName /tsn:$sqlServer
        }

        $LASTEXITCODE -ne 0 | Where-Object { $_ } | ForEach-Object { throw "Error while processing database '$databaseName'." }
    }
}

Write-Host "### Sitecore databases ready."

# ensure SQL credentials ready
$deploySqlLogin = (sqlcmd.exe -S $sqlServer -Q "SELECT COUNT(*) FROM sys.server_principals WHERE name = '$sqlLogin';" -h -1 -W | Select-Object -First 1) -eq "0"

if ($deploySqlLogin)
{
    sqlcmd.exe -S $sqlServer -Q "CREATE LOGIN [$sqlLogin] FROM Windows; EXEC sp_addsrvrolemember '$sqlLogin', sysadmin;"
}

Write-Host "### SQL credentials ready."
