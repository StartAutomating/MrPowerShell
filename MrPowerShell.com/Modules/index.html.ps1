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
    $PowerShellGallerySkip = 0,

    [switch]
    $HideGalleryTotal
)

$title = "My PowerShell Modules"
$description = "My PowerShell modules published to the PowerShell Gallery."

$fullUrl = (
    "https://www.powershellgallery.com/api/v2/Packages()?" +
        "`$filter=IsAbsoluteLatestVersion eq true and ($($GalleryConditions -join ' or '))" +
        "&`$skip=$GallerySkip&`$top=100&`$orderby=LastUpdated desc"
)

if ($psScriptRoot) { Push-Location $PSScriptRoot}

if (-not $xrpcCache) { $xrpcCache = [Ordered]@{} }

if (-not $xrpcCache['com.powershellgallery.modules']) {
    $xrpcCache['com.powershellgallery.modules'] = . ../xrpc/com.powershellgallery.modules/index.json.ps1
}

$moduleList = $xrpcCache['com.powershellgallery.modules']

Update-TypeData -TypeName com.powershellgallery.module -Force -MemberType ScriptMethod -MemberName ToHtml -Value {
    param()
    $publishedAt = $this.Published
    $attributes = [Ordered]@{
        'class' = 'powershell-gallery-module'
        'data-module-name'        = $this.id        
        'data-module-downloads'   = $this.downloadCount
        'data-module-published'   = $this.Published    
    }
    $attributeString = @($attributes.GetEnumerator() | ForEach-Object { "$($_.Key)='$($_.Value)'" }) -join ' '
    "<div $attributeString>"    
        "<h2>"
        "<a href='$($this.ProjectUrl)'>$($this.id)</a>"        
        "</h2>"
        "<a href='https://www.powershellgallery.com/packages/$($this.Id)/' >"
        "<img src='https://img.shields.io/powershellgallery/dt/$($this.Id)' />"
        "</a>"
        "<h3>v$($this.Version)</h3>"        
        "<h4>$([Web.HttpUtility]::HtmlEncode($this.Description))</h4>"
        "<h5>Downloads: $($this.downloadCount)</h5>"
        "<p>Published: <time>$($publishedAt.ToString('yyyy-MM-dd'))</time></p>"
        "<p>Created: <time>$($this.Created.ToString('yyyy-MM-dd'))</time></p>"
    "</div>"
}


$moduleList = @($moduleList | Sort-Object -Property Downloads -Descending)

"<style>"
".powershell-gallery-modules { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 2.5em; margin: 2.5em}"
".powershell-gallery-total { font-size: 1.75em; text-align: center; margin-bottom: 0.5em; }"
".powershell-gallery-sort { font-size: 1.5em; text-align: center; }"
"h1 { text-align: center; }"
"</style>"
    
"<h1>My PowerShell Modules</h1>"

if (-not $HideGalleryTotal) {
    "<div class='powershell-gallery-total'>"
        "Total Modules: $("{0:N0}" -f ($moduleList.Count))",        
            "Total Downloads: $("{0:N0}" -f ($moduleList |
                Measure-Object -Property DownloadCount -Sum |
                Select-Object -ExpandProperty Sum
            ))" -join '<br/>'
    "</div>"
}

"<div class='powershell-gallery-sort'>"
"Sort by:"
"
<select id='sort-modules'>
    <option value='random'>Random</option>
    <option value='moduleDownloads' selected>Downloads</option>
    <option value='modulePublished'>Published</option>    
    <option value='moduleName'>Name</option>    
</select>
"

$sortContainer = @'
// We can sort a container of items by:
// * Sorting on any data-* attributes
// * Setting the .order style on each child element
// Grids and flexboxes will automatically re-order the items based on the .order style.
function sortContainer(event, containerClass) {
    // The name of the data-* attribute to sort by
    // please remember that dashes in data-* attributes become camelCase in the dataset object.
    const sortBy = event.target.value;
    // The container that holds the modules
    const container = document.querySelector(containerClass);
    const children = Array.from(container.children);
    children.sort((a, b) => {
        if (sortBy === 'moduleName') {
            return a.dataset.moduleName.localeCompare(b.dataset.moduleName)
        } else if (sortBy === 'moduleDownloads') {
            return parseInt(b.dataset.moduleDownloads) - parseInt(a.dataset.moduleDownloads)
        } else if (sortBy === 'moduleCreated') {
            return parseInt(b.dataset.moduleCreated) - parseInt(a.dataset.moduleCreated)
        } else if (sortBy === 'modulePublished') {
            return new Date(b.dataset.modulePublished) - new Date(a.dataset.modulePublished)
        } else if (sortBy === 'random') {
            return Math.random() - 0.5;
        }        
    })

    for (let i = 0; i < children.length; i++) {
        children[i].style.order = i + 1
    }
}
'@

"<script>"

$sortContainer

"document.getElementById('sort-modules').addEventListener(
    'change',
    (event) => sortContainer(event, '.powershell-gallery-modules')
)"
"</script>"

"</div>"
"<div class='powershell-gallery-modules'>"
foreach ($moduleInfo in $moduleList) {
    $moduleInfo.ToHtml()
}
"</div>"

#region View Source
"<details><summary>View Source</summary>"
"<pre><code class='language-powershell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</details>"
#endregion View Source

if ($site.Includes.CopyCode) {
    . $site.Includes.CopyCode
}

if ($psScriptRoot) { Pop-Location}

