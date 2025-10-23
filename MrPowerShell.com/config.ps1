<#
.SYNOPSIS
    Configures the site
.DESCRIPTION
    Configures the site.  
    
    At the point this runs, a $Site dictionary should exist, and it should contain a list of files to build.

    Any *.json, *.psd1, or *.yaml files in the root should have already been loaded into the $Site dictionary.

    Any additional configuration or common initialization should be done here.
#>
#requires -Module Turtle
param()

#region Core
if ($psScriptRoot) {Push-Location $psScriptRoot}

if (-not $Site) { $Site = [Ordered]@{} }
if ($psScriptRoot -and -not $site.PSScriptRoot) {
    $site.PSScriptRoot = $PSScriptRoot
}
#endregion Core

#region _
if ($site.PSScriptRoot) {
    $underbarItems = 
        Get-ChildItem -Path $site.PSScriptRoot -Filter '_*' -Recurse

    $underbarFileQueue = [Collections.Queue]::new()

    foreach ($underbarItem in $underbarItems) {
        $relativePath = $underbarItem.FullName.Substring($site.PSScriptRoot.Length + 1)
        if ($underbarItem -is [IO.FileInfo]) {
            $underbarFileQueue.Enqueue($underbarItem)
        }
        else {
            foreach ($childItem in $underbarItem.GetFileSystemInfos()) {
                if ($childItem -is [IO.FileInfo]) {
                    $underbarFileQueue.Enqueue($childItem)
                }
            }            
        }
    }

    foreach ($underbarFile in $underbarFileQueue.ToArray()) {
        $relativePath = $underbarFile.FullName.Substring($site.PSScriptRoot.Length + 1)
        $pointer = $site
        $hierarchy = @($relativePath -split '[\\/]')
        for ($index = 0; $index -lt ($hierarchy.Length - 1); $index++) {
            $subdirectory = $hierarchy[$index] -replace '_'
            if (-not $pointer[$subdirectory]) {
                $pointer[$subdirectory] = [Ordered]@{}
            }
            $pointer = $pointer[$subdirectory]
        }
                
        $propertyName = $hierarchy[-1] -replace '_' -replace "$([Regex]::Escape($underbarFile.Extension))$"
        
        $fileData = 
            switch ($underbarFile.Extension) {
                '.ps1' {
                    $ExecutionContext.SessionState.InvokeCommand.GetCommand($underbarFile.FullName, 'ExternalScript')
                }
                '.txt' {
                    Get-Content -LiteralPath $underbarFile.FullName
                }
                '.json' {
                    Get-Content -LiteralPath $underbarFile.FullName -Raw | ConvertFrom-Json
                }
                '.psd1' {
                    Get-Content -LiteralPath $underbarFile.FullName -Raw | ConvertFrom-StringData
                }
                '.yaml' {
                    'YaYaml' | RequireModule
                    Get-Content -LiteralPath $underbarFile.FullName -Raw | ConvertFrom-Yaml                    
                }
                '.csv' {
                    Import-Csv -LiteralPath $underbarFile.FullName
                }
                '.tsv' {
                    Import-Csv -LiteralPath $underbarFile.FullName -Delimiter "`t"
                }
                default {
                    Get-Content -LiteralPath $underbarFile.FullName -Raw
                }
            }

        $pointer[$propertyName] = $fileData            
    }
}
#region _

#region At Protocol

#region At Data

if (-not $site.AtData) {
    # If we have a script root, we'll use it to set the working directory.
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
}
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
    'GitHub' = . $site.includes.Feather 'GitHub'
    'RSS' = . $site.includes.Feather 'RSS'
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
    # "Gists"  = "https://MrPowerShell.com/Gists"
    "GitHub" = "/GitHub"    
    "Memes"  = "/Memes"    
    "Mentions" = "/Mentions"
    "Modules" = "/Modules"
    "Tags" = "/Tags"
    "YouTube" = "/YouTube"
}
#endregion Site Menus

#region Site Background

$doodle = @(
    'forward', 100,'right', 90 * 2
    'forward', 50,'right', 90 * 2
    'forward', 100,'right', 90
    'forward', 25, 'right', 90 * 2
    'forward', 50
)

# Randomizing site background a bit
$backgroundPatternAnimations = 
    [Ordered]@{
        type = 'scale'    ; values = 0.66,0.33, 0.66 ; repeatCount = 'indefinite' ;dur = "277s"; additive = 'sum';id ='scale-pattern'
    }, [Ordered]@{
        type = 'rotate'   ; values = 0, 360 ;repeatCount = 'indefinite'; dur = "317s"; additive = 'sum'; id ='rotate-pattern'
    }, [Ordered]@{
        type = 'skewX'   ; values = "0;45;0"; dur = "401s"; additive = 'sum'; id ='translate-pattern'
    }, [Ordered]@{
        type = 'skewY'   ; values = "0;-45;0"; dur = "503s"; additive = 'sum'; id ='translate-pattern'
    }

$sitebackgrounds = @(

    {turtle Flower 30 60 6}

    {turtle Flower 30 (360/8) 8}

    {turtle SierpinskiTriangle 15 4 }
    
    {turtle SierpinskiArrowheadCurve 15 4}

    {turtle KochSnowflake 4.2 4}
    
    {turtle BoxFractal 4.2 4}

    # {turtle Flower 15 5 40 72}

    {turtle Flower 15 9 40 40}

    {turtle rotate 72 square 84 jump 84}

    {turtle rotate 20 @('circle',15,0.5,'circle',15,-0.5, 'rotate', 90 * 4)}

    {turtle @('rotate', 90, 'circle',42,0.25,'circle',42,-0.25 * 4)}

    {turtle @('rotate', 45, 'circle',21,0.25,'circle',21,-0.25 * 8)}

    {turtle rotate (360/5) @('circle',15,0.5,'circle',15,-0.5, 'rotate', 72 * 5)}
    
    {
        turtle square 42 @('rotate', -60, 'forward',42, 'rotate', 120, 'forward',42, 'rotate', 30 * 4)
    }

    { 
        # Golden triangle/square star
        $goldenRatio = (1 + [Math]::sqrt(5))/2
        turtle @('rotate', -60, 'forward',(42*$goldenRatio), 'rotate', 120, 'forward',(42*$goldenRatio), 'rotate', 30 * 4)
    }

    {
        # Golden hexagon
        $goldenRatio = (1 + [Math]::sqrt(5))/2
        $BaseSideCount = 6
        turtle @(
            'rotate', (360/$BaseSideCount/-2)
            foreach ($n in 1..$BaseSideCount) {
                'forward'
                42 * $goldenRatio
                'rotate'
                360/$BaseSideCount
            }
        ) * 2
        
    }

    {
        # Golden hex flowers
        $goldenRatio = (1 + [Math]::sqrt(5))/2
        $BaseSideCount = 6
        turtle (@(
            'rotate', (360/$BaseSideCount/-2)
            foreach ($n in 1..$BaseSideCount) {
                'forward'
                42 * $goldenRatio
                'rotate'
                360/$BaseSideCount
            }
            'rotate', (360/($BaseSideCount)/4)
        ) * ($BaseSideCount * 4))
    }

    {        
        turtle @($doodle * 4)
    }

    {        
        turtle ($doodle,'right','10', 'forward', '50' * 36)
    }

    {
        turtle ($doodle,'left','45', 'forward', '100' * 8)
    }

    {
        turtle ($doodle,'left','30', 'forward', '75' * 3)
    }

    {
        turtle @('StepSpiral',23, 90, 4, 'rotate',90 * 4)
    }

    {
        turtle spirolateral 42 60 8
    }

    {
        turtle rotate -30 @('spirolateral',23,60,6,@(1,3),'rotate', 60 * 6 )
    }

    {
        turtle spirolateral 23 90 11 @(3,4,5) 
    }

    {
        turtle spirolateral 23 120 6 @(1,3)
    }

    {
        turtle spirolateral 23 144 8
    }
    
    {
        turtle @('StepSpiral',23, 60, 4 * 3)
    }

    {
        turtle @('StepSpiral',23, 120, 16, 18)
    }

    {
        turtle @('StepSpiral',23, 60, 16, 19 * 6)
    }

    {
        turtle @('ArcRight', 23, 60, 'ArcLeft', 23, 160 * 24)
    }

    {
        turtle Pentaplexity 23 4
    }

    {
        turtle BoardFractal 23 4
    }

    {
        turtle CrystalFractal 23 4
    }    
)

$siteBackground = $sitebackgrounds | Get-Random
        
$site.Background = . $siteBackground|
    Set-Turtle PatternAnimation $backgroundPatternAnimations |
    Set-Turtle PathAttribute @{opacity=.2} |
    Select-Object -ExpandProperty Pattern
#endregion Site Background