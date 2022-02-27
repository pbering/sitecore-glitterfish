[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path $_ -PathType 'Container' })]
    [string]$SourcePath
    ,
    [Parameter(Mandatory = $true)]
    [string]$InstallPath
    ,
    [Parameter(Mandatory = $true)]
    [string]$DataPath
    ,
    [Parameter(Mandatory = $true)]
    [string]$Server
)

if ((Test-Path $InstallPath) -eq $false)
{
    New-Item -Path $InstallPath -ItemType "Directory" | Out-Null
}

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

$sql = New-Object Microsoft.SqlServer.Management.Smo.Server($Server)

$sqlDefaultDataPath = $sql.Properties["DefaultFile"].Value

Get-ChildItem -Path $SourcePath -Filter "*.dacpac" | ForEach-Object {
    $databaseName = $_.BaseName
    $dacpacPath = Join-Path $SourcePath ("\{0}" -f $_.Name)

    sqlpackage.exe /a:Publish /sf:$dacpacPath /tdn:$databaseName /tsn:$Server /p:AllowIncompatiblePlatform=True /q

    sqlcmd.exe -S $Server -Q "EXEC MASTER.dbo.sp_detach_db @dbname = N'$databaseName', @keepfulltextindexfile = N'false'"

    Copy-Item -Path (Join-Path $sqlDefaultDataPath "$databaseName`_Primary.*") -Destination $InstallPath
}

$sql.Properties["DefaultFile"].Value = $DataPath
$sql.Properties["DefaultLog"].Value = $DataPath
$sql.Alter()