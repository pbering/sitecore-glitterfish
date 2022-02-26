$cleanDatabasesPath = "C:\clean_databases"
$sqlLogin = "IIS APPPOOL\DefaultAppPool"
$sqlDataRoot = "C:\mssql"
$sqlServer = ".\SQLEXPRESS"
$sqlServiceName = "MSSQL$`SQLEXPRESS"
$sqlLoginTimeout = 30

# ensure SQL is running
Write-Host "### Waiting on SQL service '$sqlServiceName'."

(Get-Service $sqlServiceName ).WaitForStatus("Running")

Write-Host "### SQL service '$sqlServiceName' ready."

# ensure databases ready
$noSitecoreDatabases = $null -eq (Get-ChildItem -Path $sqlDataRoot -Filter "Sitecore*.mdf")

if ($noSitecoreDatabases)
{
    Write-Host "### Sitecore databases not found in '$sqlDataRoot', seeding clean databases from '$cleanDatabasesPath'..."

    Get-ChildItem -Path $cleanDatabasesPath | Copy-Item -Destination $sqlDataRoot
}

Get-ChildItem -Path $sqlDataRoot -Filter "*.mdf" | ForEach-Object {
    $databaseName = $_.BaseName.Replace("_Primary", "")
    $mdfPath = $_.FullName
    $ldfPath = $mdfPath.Replace(".mdf", ".ldf")
    $sqlcmd = "IF EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = '$databaseName') BEGIN EXEC sp_detach_db [$databaseName] END;CREATE DATABASE [$databaseName] ON (FILENAME = N'$mdfPath'), (FILENAME = N'$ldfPath') FOR ATTACH;"

    Write-Host "### Attaching '$databaseName'..."

    sqlcmd.exe -S $sqlServer -Q $sqlcmd -l $sqlLoginTimeout
}

Write-Host "### Databases ready."

# ensure SQL credentials ready
$deploySqlLogin = (sqlcmd.exe -S $sqlServer -Q "SELECT COUNT(*) FROM sys.server_principals WHERE name = '$sqlLogin';" -h -1 -W -l $sqlLoginTimeout | Select-Object -First 1) -eq "0"

if ($deploySqlLogin)
{
    sqlcmd.exe -S $sqlServer -Q "CREATE LOGIN [$sqlLogin] FROM Windows; EXEC sp_addsrvrolemember '$sqlLogin', sysadmin;" -l $sqlLoginTimeout
}

Write-Host "### SQL credentials ready."

# ensure Sitecore admin password
. (Join-Path $PSScriptRoot "\SetSitecoreAdminPassword.ps1") -ResourcesDirectory $PSScriptRoot -SitecoreAdminPassword $env:SITECORE_ADMIN_PASSWORD -SqlServer $sqlServer

Write-Host "### Sitecore admin credentials ready."
