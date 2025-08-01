<#
.SYNOPSIS
    Configures the site
.DESCRIPTION
    Configures the site.  
    
    At the point this runs, a $Site dictionary should exist, and it should contain a list of files to build.

    Any *.json, *.psd1, or *.yaml files in the root should have already been loaded into the $Site dictionary.

    Any additional configuration or common initialization should be done here.
#>

#region At Protocol

#region At Data
# If we have a script root, we'll use it to set the working directory.
if ($psScriptRoot) {Push-Location $psScriptRoot}

if (-not $Site) {
    $Site = [Ordered]@{}
}

# Create a new DataSet to hold the At Protocol data.
$atProtocolData = [Data.DataSet]::new('AtProtocol')
# Look up in the path
$parentPath = $PSScriptRoot | Split-Path -Parent
# Find any directories that start with did* in the parent path.
$atJsonFiles = $parentPath | 
    Get-ChildItem -Filter did* |
    Get-ChildItem -Directory | 
    Get-ChildItem -Filter *.json # and get any json files in them.

foreach ($jsonFile in $atJsonFiles) {
    $jsonText = Get-Content -Path $jsonFile.FullName -Raw
    $jsonObject = ConvertFrom-Json -InputObject $jsonText
    $recordType = $jsonObject.commit.record.'$type'
    if (-not $recordType) { continue }
    
    if (-not $atProtocolData.Tables[$recordType]) {
        $dataTable = $atProtocolData.Tables.Add($recordType)
        $dataTable.Columns.AddRange(@(
            [Data.DataColumn]::new('did', [string], '', 'Attribute'),
            [Data.DataColumn]::new('rkey', [string], '', 'Attribute')
            [Data.DataColumn]::new('createdAt', [DateTime], '', 'Attribute'),
            [Data.DataColumn]::new('atUri', [string], "'at://' + did + '/$recordType/' + rkey", 'Attribute')
            [Data.DataColumn]::new('json', [string], '', 'SimpleContent')
            [Data.DataColumn]::new('message', [object], '', 'Hidden')
        ))
        $dataTable.PrimaryKey = $dataTable.Columns['did', 'rkey']
        $dataTable.DefaultView.Sort = 'createdAt ASC'
    } else {
        $dataTable = $atProtocolData.Tables[$recordType]
    }

    $dataRow = $dataTable.NewRow()
    $dataRow['did'] = $jsonObject.did
    $dataRow['rkey'] = $jsonObject.commit.rkey    
    $dataRow['createdAt'] = 
        if ($jsonObject.commit.record.createdAt) { $jsonObject.commit.record.createdAt }
        else { [DBNull]::Value }
    $jsonObject.pstypenames.insert(0, $recordType)
    $dataRow['message'] = $jsonObject
    $dataRow['json'] = $jsonText    
    $dataTable.Rows.Add($dataRow)
}

if ($site -is [Collections.IDictionary]) {
    $site.AtData = $atProtocolData
}

#endregion At Data

#region at.zip 
$atPackage = [IO.Packaging.Package]::Open("$pwd/at.zip", "OpenOrCreate", "ReadWrite")
foreach ($dataTable in $atProtocolData.Tables) {
    $dataSchemaPart =
        if (-not $atPackage.PartExists("/$($dataTable.TableName).xsd")) {
            $atPackage.CreatePart("/$($dataTable.TableName).xsd", "application/xml", 'Maximum')
        } else {
            $atPackage.GetPart("/$($dataTable.TableName).xsd")
        }
    $dataSchemaStream = $dataSchemaPart.GetStream()
    $dataTable.WriteXmlSchema($dataSchemaStream)
    $dataSchemaStream.Close()
    $dataSchemaStream.Dispose()


    $dataTablePart =
        if (-not $atPackage.PartExists("/$($dataTable.TableName).xml")) {
            $atPackage.CreatePart("/$($dataTable.TableName).xml", "application/xml", 'Maximum')
        } else {
            $atPackage.GetPart("/$($dataTable.TableName).xml")
        }

    $dataTableStream = $dataTablePart.GetStream()
    $dataTable.WriteXml($dataTableStream)
    $dataTableStream.Close()
    $dataTableStream.Dispose()
} 
$atPackage.Close()
$atPackage.Dispose()

if ($psScriptRoot) {Pop-Location}
#endregion at.zip

#endregion At Protocol

#region Site Metadata
$Site.Title = 'MrPowerShell'
#endregion Site Metadata

#region Site Icons
$Site.Icon  = [Ordered]@{
    'BlueSky' = 
        Get-Content -Path (
            Join-Path $PSScriptRoot Assets | 
                Join-Path -ChildPath 'BlueSky.svg'
        ) -Raw
    'GitHub' = 
        Get-Content -Path (
            Join-Path $PSScriptRoot Assets | 
                Join-Path -ChildPath 'GitHub.svg'
        ) -Raw
    'RSS' = 
        Get-Content -Path (
            Join-Path $PSScriptRoot Assets | 
                Join-Path -ChildPath 'RSS.svg'
        ) -Raw
}
#endregion Site Icons

#region Site Menus
$Site.Logo = Get-Content -Path (
    Join-Path $PSScriptRoot 'MrPowerShell-Animated.svg'
) -Raw

$site.Taskbar = [Ordered]@{
    'BlueSky' = 'https://bsky.app/profile/mrpowershell.com'
    'GitHub' = 'https://github.com/StartAutomating/MrPowerShell'
    'RSS' = 'https://MrPowerShell.com/RSS/index.rss'
}

$site.HeaderMenu = [Ordered]@{
    "Gists"  = "https://MrPowerShell.com/Gists"
    "GitHub" = "https://MrPowerShell.com/GitHub"    
    "Memes"  = "https://MrPowerShell.com/Memes"    
    "Mentions" = "https://MrPowerShell.com/Mentions"
    "Modules" = "https://MrPowerShell.com/Modules"
    "Tags" = "https://MrPowerShell.com/Tags"
    "YouTube" = "https://MrPowerShell.com/YouTube"
}
#endregion Site Menus