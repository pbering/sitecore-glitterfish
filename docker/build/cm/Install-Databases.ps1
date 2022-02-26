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

if ((Test-Path $DataPath) -eq $false)
{
    New-Item -Path $DataPath -ItemType "Directory" | Out-Null
}

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

$sql = New-Object Microsoft.SqlServer.Management.Smo.Server($Server)
$sql.Properties["DefaultFile"].Value = $SourcePath
$sql.Properties["DefaultLog"].Value = $SourcePath
$sql.Alter()

Get-ChildItem -Path $SourcePath -Filter "*.dacpac" | ForEach-Object {
    $databaseName = $_.BaseName
    $dacpacPath = Join-Path $SourcePath ("\{0}" -f $_.Name)

    sqlpackage.exe /a:Publish /sf:$dacpacPath /tdn:$databaseName /tsn:$Server /p:AllowIncompatiblePlatform=True

    sqlcmd.exe -S $Server -Q "EXEC MASTER.dbo.sp_detach_db @dbname = N'$databaseName', @keepfulltextindexfile = N'false'"

    Copy-Item -Path (Join-Path $SourcePath "$databaseName`_Primary.*") -Destination $InstallPath
}

$sql = New-Object Microsoft.SqlServer.Management.Smo.Server($Server)
$sql.Properties["DefaultFile"].Value = $DataPath
$sql.Properties["DefaultLog"].Value = $DataPath
$sql.Alter()