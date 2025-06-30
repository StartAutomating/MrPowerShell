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
    "<div class='powershell-gallery-module'>"    
        "<h2>"
        "<a href='$($this.ProjectUrl)'>$($this.Name)</a>"        
        "</h2>"
        "<a href='https://www.powershellgallery.com/packages/$($this.Name)/' >"
        "<img src='https://img.shields.io/powershellgallery/dt/$($this.Name)' />"
        "</a>"
        "<h3>v$($this.Version)</h3>"
        "<h4>$([Web.HttpUtility]::HtmlEncode($this.Description))</h4>"
        "<p>Created: $($this.CreatedAt.ToString('yyyy-MM-dd'))</p>"
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
"h1 { text-align: center; }"
"</style>"
"<h1>My PowerShell Modules</h1>"
if ($ShowGalleryTotal) {
    "<div class='powershell-gallery-total'>Total Downloads: $("{0:N0}" -f ($moduleList | Measure-Object -Property Downloads -Sum | Select-Object -ExpandProperty Sum))</div>"
}

"<div class='powershell-gallery-modules'>"
foreach ($moduleInfo in $moduleList) {
    $moduleInfo.ToHtml()
}
"</div>"

# irm "https://www.powershellgallery.com/api/v2/Packages()?`$filter=IsAbsoluteLatestVersion eq true and CompanyName eq 'Start-Automating'&`$skip=$Skip&`$top=100&`$orderby=LastUpdated desc"



