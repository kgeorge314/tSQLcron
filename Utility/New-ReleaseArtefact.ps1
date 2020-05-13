[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $ReleaseManifestFilePath
    ,
    [Parameter(Mandatory=$true)]
    [string]
    $InstallScriptPath
    ,
    [Parameter(Mandatory=$false)]
    [string]
    $TestCaseScriptPath
)

$ManifestFile = Get-Content  $ReleaseManifestFilePath | ConvertFrom-Csv | Sort-Object -Property Order

$Manifest = @()
foreach ($m in $ManifestFile) {

    $ItemPath = Get-item -Path $m.file_name

    $Manifest += @{
        'Order'     = $m.order;
        'item_type' = $m.item_type;
        'file_name' = $ItemPath;
    }
}

$ReleasesFileContent = @()
foreach ($sql in ($Manifest | Where-Object -Property item_type -EQ 'TSQL' | Sort-Object -Property Order )) {
    $FileContent = Get-content -path $sql.file_name
    
    $ReleasesFileContent += $FileContent
    $ReleasesFileContent += "`r`n--`r`nGO`r`n--`r`n"
}

$OutPutFile = $ReleasesFileContent -join "`r`n"
$OutPutFile | Out-File -FilePath $InstallScriptPath

$TestCasesFilesContent = @()
foreach ($sql in ($Manifest | Where-Object -Property item_type -EQ 'TSQL' | Sort-Object -Property Order )) {
    $FileContent = Get-content -path $sql.file_name
    
    $TestCasesFilesContent += $FileContent
    $TestCasesFilesContent += "`r`n--`r`nGO`r`n--`r`n"
}

$OutPutFile = $TestCasesFilesContent -join "`r`n"

$OutPutFile | Out-File -FilePath $TestCaseScriptPath