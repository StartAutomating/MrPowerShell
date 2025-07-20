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
        "CompanyName eq 'Start Automating'",         
        "Authors eq 'James Brundage'",
        "Authors eq 'JamesBrundage'",
        "Authors eq 'Start-Automating'",
        "Authors eq 'Start Automating'",
        "Id eq 'ShowUI'"
    ),

    [switch]
    $HideGalleryTotal,
    
    [int]
    $Skip = 0
)

$title = "My PowerShell Modules"
$description = "My PowerShell modules published to the PowerShell Gallery."

$fullUrl = (
    "https://www.powershellgallery.com/api/v2/Packages()?" +
        "`$filter=IsAbsoluteLatestVersion eq true and ($($GalleryConditions -join ' or '))" +
        "&`$skip=$Skip&`$top=100&`$orderby=LastUpdated desc"
)




if (-not $script:MyModuleGalleryInfoCache) {
    $script:MyModuleGalleryInfoCache = [Ordered]@{}
}

if (-not $script:MyModuleGalleryInfoCache[$fullUrl]) {
    $script:MyModuleGalleryInfoCache[$fullUrl] = Invoke-RestMethod $fullUrl
}
$moduleList = $script:MyModuleGalleryInfoCache[$fullUrl]

if ($script:MyModuleGalleryInfoCache[$fullUrl] -is [xml]) {
    $script:MyModuleGalleryInfoCache[$fullUrl].Save("$psScriptRoot/index.xml")
}

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

Update-TypeData -TypeName PowerShellGallery.Module -Force -MemberType ScriptProperty -MemberName UpdatedAt -Value {
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
        'data-module-created-at'  = ($this.properties.Created.'#text' -as [DateTime]).ToString('o')
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
        "<h5>Downloads: $($this.Downloads)</h5>"
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
                Measure-Object -Property Downloads -Sum |
                Select-Object -ExpandProperty Sum
            ))" -join '<br/>'
    "</div>"
}

"<div class='powershell-gallery-sort'>"
"Sort by:"
"<select id='sort-modules'>"
    "<option value='moduleDownloads' selected>Downloads</option>"
    "<option value='moduleCreatedAt'>Created At</option>"
    "<option value='moduleName'>Name</option>"
    "<option value='moduleVersion'>Version</option>"
"</select>"

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

        // Random sorts are just a 50/50 chance to be sorted
        if (sortBy === 'random') { return Math.random() - 0.5; }
        // Anything that looks like a version should be sorted as a version
        if (sortBy.match(/Version/i)) {
            // since versions should be sorted descending, we reverse the localeCompare result.
            return a.dataset[sortBy].localeCompare(b.dataset[sortBy], undefined, {numeric: true}) * -1;
        }

        // Next, see if they can be parsed as dates
        var aDate = Date.parse(a.dataset[sortBy]);
        var bDate = Date.parse(b.dataset[sortBy]);
        // If both are valid dates, sort by date
        if (!isNaN(aDate) && !isNaN(bDate)) {
            return bDate - aDate;
        }

        // Next, see if they can be parsed as numbers
        var aNumber = Number(a.dataset[sortBy]);
        var bNumber = Number(b.dataset[sortBy]);
        // If both are valid numbers, sort by number
        if (!isNaN(aNumber) && !isNaN(bNumber)) {
            return bNumber - aNumber;
        }

        // Finally, sort as strings
        return a.dataset[sortBy].localeCompare(b.dataset[sortBy]);
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

# irm "https://www.powershellgallery.com/api/v2/Packages()?`$filter=IsAbsoluteLatestVersion eq true and CompanyName eq 'Start-Automating'&`$skip=$Skip&`$top=100&`$orderby=LastUpdated desc"



