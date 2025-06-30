<#
.SYNOPSIS
    Gets my modules.
.DESCRIPTION
    Gets my module metadata from the PowerShell Gallery, without using any modules.

    Then displays them as HTML.
.EXAMPLE
    ./index.html.ps1
.LINK
    https://MrPowerShell.com/Modules
#>
param(
    [Alias('GalleryCondition')]
    [string[]]
    $GalleryConditions = @(
        "CompanyName eq 'Start-Automating'", 
        "Authors eq 'James Brundage'"
    ),

    [switch]
    $ShowGalleryTotal,
    
    [int]
    $Skip = 0
)




$fullUrl = (
    "https://www.powershellgallery.com/api/v2/Packages()?" +
        "`$filter=IsAbsoluteLatestVersion eq true and ($($GalleryConditions -join ' or '))" +
        "&`$skip=$Skip&`$top=100&`$orderby=LastUpdated desc"
)




if (-not $script:MyModuleGalleryInfoCache) {
    $script:MyModuleGalleryInfoCache = [Ordered]@{}
}

if (-not $script:MyModuleGalleryInfoCache[$fullUrl]) {
    $script:MyModuleGalleryInfoCache[$fullUrl] = Invoke-RestMethod $fullUrl -Verbose
}
$moduleList = $script:MyModuleGalleryInfoCache[$fullUrl]


Update-TypeData -TypeName PowerShellGallery.Module -MemberType ScriptProperty -MemberName Name -Value {
    $this.properties.ID
} -Force

Update-TypeData -TypeName PowerShellGallery.Module -MemberType ScriptProperty -MemberName CompanyName -Value {
    $this.properties.CompanyName
} -Force

Update-TypeData -TypeName PowerShellGallery.Module -MemberType ScriptProperty -MemberName Downloads -Value {
    $this.properties.DownloadCount.'#text' -as [int]
} -Force

Update-TypeData -TypeName PowerShellGallery.Module -MemberType ScriptProperty -MemberName Description -Value {
    $this.properties.Description
} -Force

Update-TypeData -TypeName PowerShellGallery.Module -MemberType ScriptProperty -MemberName Version -Value {
    $this.properties.Version -as [Version]
} -Force

Update-TypeData -TypeName PowerShellGallery.Module -MemberType ScriptProperty -MemberName LastUpdated -Value {
    $this.properties.LastUpdated.'#text' -as [DateTime]
} -Force

Update-TypeData -TypeName PowerShellGallery.Module -MemberType ScriptProperty -MemberName ProjectUrl -Value {
    if ($this.properties.ProjectUrl) {
        $this.properties.ProjectUrl -as [Uri]
    } elseif ($this.properties.gallerydetailsurl) {
        $this.properties.gallerydetailsurl -as [Uri]        
    } else {
        "https://www.powershellgallery.com/packages/$($this.Name)/$($this.Version)" -as [Uri]
    }
} -Force

Update-TypeData -TypeName PowerShellGallery.Module -MemberType ScriptProperty -MemberName Authors -Value {
    $this.properties.Authors -split ',\s{0,}'
} -Force

Update-TypeData -TypeName PowerShellGallery.Module -Force -MemberType ScriptProperty -MemberName CreatedAt -Value {
    param()
    
    $this.properties.Created.'#text' -as [DateTime]
}

Update-TypeData -TypeName PowerShellGallery.Module -Force -MemberType ScriptMethod -MemberName ToHtml -Value {
    param()
    $attributes = [Ordered]@{
        'class' = 'powershell-gallery-module'
        'data-module-name'        = $this.Name
        'data-module-version'     = $this.Version
        'data-module-downloads'   = $this.Downloads
        'data-module-created-at'  = $this.CreatedAt.ToString('o')
        'data-module-last-updated'= $this.LastUpdated.ToString('o')
    }
    $attributeString = @($attributes.GetEnumerator() | ForEach-Object { "$($_.Key)='$($_.Value)'" }) -join ' '
    "<div $attributeString>"    
        "<h2>"
        "<a href='$($this.ProjectUrl)'>$($this.Name)</a>"        
        "</h2>"
        "<a href='https://www.powershellgallery.com/packages/$($this.Name)/' >"
        "<img src='https://img.shields.io/powershellgallery/dt/$($this.Name)' />"
        "</a>"
        "<h3>v$($this.Version)</h3>"
        "<h4>$([Web.HttpUtility]::HtmlEncode($this.Description))</h4>"
        "<p>Created: $($this.CreatedAt.ToString('yyyy-MM-dd'))</p>"
        "<p>Last Updated: $($this.LastUpdated.ToString('yyyy-MM-dd'))</p>"
    "</div>"
}


$moduleList = @(foreach ($moduleInfo in $moduleList) {
    if ($moduleInfo.pstypenames -notcontains 'PowerShellGallery.Module') {
        $moduleInfo.pstypenames.insert(0, 'PowerShellGallery.Module')
    }
    $moduleInfo        
})


$moduleList = @($moduleList | Sort-Object -Property Downloads -Descending)
"<style>"
".powershell-gallery-modules { display: grid; grid-template-columns: repeat(auto-fit, minmax(42em, 1fr)); gap: 2.5em; margin: 5em}"
".powershell-gallery-total  { font-size: 2em; text-align: center; }"
".powershell-gallery-sort   { font-size: 1.5em; text-align: center;}"
"h1 { text-align: center; }"
"</style>"
"<h1>My PowerShell Modules</h1>"
if ($ShowGalleryTotal) {
    "<div class='powershell-gallery-total'>Total Downloads: $("{0:N0}" -f ($moduleList | Measure-Object -Property Downloads -Sum | Select-Object -ExpandProperty Sum))</div>"
}
"<div class='powershell-gallery-sort'>"
"Sort by:"
"<select id='sort-modules'>"
"<option value='downloads' selected>Downloads</option>"
"<option value='created'>Created At</option>"
"<option value='lastUpdated'>Last Updated</option>"
"<option value='name'>Name</option>"
"<option value='version'>Version</option>"
"</select>"
"<script>"
"document.getElementById('sort-modules').addEventListener('change', function(event) {"
"    const sortBy = event.target.value;"
"    const container = document.querySelector('.powershell-gallery-modules');"
"    const modules = Array.from(container.children);"
"    modules.sort((a, b) => {"
"        if (sortBy === 'downloads') {"
"            return parseInt(b.dataset.moduleDownloads) - parseInt(a.dataset.moduleDownloads);"
"        } else if (sortBy === 'created') {"
"            return new Date(b.dataset.moduleCreatedAt) - new Date(a.dataset.moduleCreatedAt);"
"        } else if (sortBy === 'lastUpdated') {"
"            return new Date(b.dataset.moduleLastUpdated) - new Date(a.dataset.moduleLastUpdated);"
"        } else if (sortBy === 'name') {"
"            return a.dataset.moduleName.localeCompare(b.dataset.moduleName);"
"        } else if (sortBy === 'version') {"
"            return a.dataset.moduleVersion.localeCompare(b.dataset.moduleVersion, undefined, {numeric: true}) * -1;"
"        }"
"        return 0;"
"    });"
"    for (let i = 0; i < modules.length; i++) {"
"        modules[i].style.order = i + 1;"
"    }"
"});"
"</script>"
"</div>"
"<div class='powershell-gallery-modules'>"
foreach ($moduleInfo in $moduleList) {
    $moduleInfo.ToHtml()
}
"</div>"

# irm "https://www.powershellgallery.com/api/v2/Packages()?`$filter=IsAbsoluteLatestVersion eq true and CompanyName eq 'Start-Automating'&`$skip=$Skip&`$top=100&`$orderby=LastUpdated desc"



