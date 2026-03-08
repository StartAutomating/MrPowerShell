<#
.SYNOPSIS
    site.standard.publication
.DESCRIPTION
    Defines the site.standard.publication.
.NOTES
    This endpoint contains data about this website
.LINK
    https://standard.site/
#>
param(
    # The Standard Site Publication Data.    
    [Alias(
        'site.standard.publication',
        'standard.site.publication',
        'SiteStandardPublication'
    )]
    [Collections.IDictionary]
    $StandardSitePublication = [Ordered]@{
        url = 'https://MrPowerShell.com/'
        name = "MrPowerShell"
        description = 
            "Jack of all trades, master of PowerShell.  Personal webpage and ever-evolving internet experiment"
        preferences = [PSCustomObject]@{
            showInDiscover = $true
        }
        # site.standard.publications can have any number of additional properties
        
        # Let's include the repository
        repository = "https://github.com/StartAutomating/MrPowerShell"
        # and the source to this file
        source = "/MrPowerShell.com/xrpc/site.standard.publication/index.json.ps1"
    }
)

[PSCustomObject](
    [Ordered]@{
        '$type' = 'site.standard.publication'
        PSTypeName = 'site.standard.publication'
    } + $StandardSitePublication
)