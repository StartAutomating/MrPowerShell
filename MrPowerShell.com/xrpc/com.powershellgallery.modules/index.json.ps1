<#
.SYNOPSIS
    Gets PowerShell modules
.DESCRIPTION
    Gets a snapshot of PowerShell modules from the gallery
#>
[OutputType('{
    "type": "object",
    "required": ["id", "url"],
    "properties": {
        "id": {
            "type": "string",
            "description": "The package id"
        },
        "url": {
            "type": "string",
            "description": "The package url"
        },
        "authors": {
            "type": "string",
            "description": "The authors of the package"
        },
        "companyName": {
            "type": "string",
            "description": "An optional company name"
        },
        "created": {
            "type": "datetime",
            "description": "The time the package was created"
        },
        "description": {
            "type": "string",
            "description": "A description of the package"
        },
        "downloadCount": {
            "type": "int",
            "description": "The number of downloads for the package"
        },
        "guid": {
            "type": "string",
            "description": "The globally unique identifier for the package"
        },
        "lastUpdated": {
            "type": "datetime",
            "description": "The last time the package was updated"
        },
        "licenseUrl": {
            "type": "string",
            "description": "An optional license url"
        },
        "packageHash": {
            "type": "string",
            "description": "The hash of the package"
        },
        "packageHashAlgorithm": {
            "type": "string",
            "description": "The package hash algorithm"
        },
        "published": {
            "type": "datetime",
            "description": "The date the package was published"
        },
        "projectUrl": {
            "type": "url",
            "description": "A Project Url"
        },
        "releaseNotes": {
            "type": "string",
            "description": "Optional release notes.  These may be treated as markdown."
        },
        "tags": {
            "type": "string",
            "description": "Optional tags"
        },        
        "version": {
            "type": "string",
            "description": "The package version"
        }
    }
}')]
param(
    [Alias('PowerShellGalleryCondition')]
    [string[]]
    $PowerShellGalleryConditions = @(
        "CompanyName eq 'Start-Automating'",
        "CompanyName eq 'Start Automating'",         
        "Authors eq 'James Brundage'",
        "Authors eq 'JamesBrundage'",
        "Authors eq 'Start-Automating'",
        "Authors eq 'Start Automating'",
        "Id eq 'ShowUI'"
    ),

    [int]
    $PowerShellGallerySkip = 0
)


$myOutputSchema = $MyInvocation.MyCommand.OutputType -match '^{' | ConvertFrom-Json
$myOutputProperties = $myOutputSchema.properties.psobject.properties.name

if ($PowerShellGalleryConditions) {
    $fullUrl = (
        "https://www.powershellgallery.com/api/v2/Packages()?" +
            "`$filter=IsAbsoluteLatestVersion eq true and ($(
                $PowerShellGalleryConditions -join ' or '
            ))" +
            "&`$skip=$PowerShellGallerySkip&`$top=100&`$orderby=LastUpdated desc"
    )

    if (-not $script:MyModuleGalleryInfoCache) {
        $script:MyModuleGalleryInfoCache = [Ordered]@{}
    }

    if (-not $script:MyModuleGalleryInfoCache[$fullUrl]) {
        $script:MyModuleGalleryInfoCache[$fullUrl] = Invoke-RestMethod $fullUrl
    }
    $moduleList = $script:MyModuleGalleryInfoCache[$fullUrl] | 
        Sort-Object { $_.properties.downloadCount.'#text' -as [int]} -Descending
        
    foreach ($moduleInfo in $moduleList) {

        $moduleData = [Ordered]@{
            '$type' = 'com.powershellgallery.module'
            PSTypeName = 'com.powershellgallery.module'
            id = "$($moduleInfo.properties.id)"
            url = "https://powershellgallery.com/packages/$($moduleInfo.properties.Id)"
        }

        foreach (
            $propertyName in $myOutputProperties
        ) {
            $moduleProperty = $moduleInfo.properties.$propertyName
            
            if (-not $moduleProperty) { continue }
            $propertyData = switch ($moduleProperty.type) {
                edm.datetime {
                    $moduleProperty.'#text' -as [DateTime]
                }
                edm.int32 {
                    $moduleProperty.'#text' -as [int]
                }
                edm.boolean {
                    $moduleProperty.'#text' -eq 'true'
                }
                default {
                    $moduleProperty
                }
            }

            if ($propertyData) {
                $moduleData[$propertyName] = $propertyData
            }
                
        }             
        
        [PSCustomObject]$moduleData
    }   
}
