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

# Set some page metadata
$title = "My PowerShell Modules"
$description = "My PowerShell modules published to the PowerShell Gallery."

# Make sure we're in the right place
if ($psScriptRoot) { Push-Location $PSScriptRoot }

# If there is no cache, create one
if (-not $script:Cache) { $script:Cache = [Ordered]@{} }

# If we have not already cached our modules
if (-not $script:Cache['com.powershellgallery.modules']) {
    # Just call the xrpc index script, which will return the objects.
    $script:Cache['com.powershellgallery.modules'] = . ../xrpc/com.powershellgallery.modules/index.json.ps1
}

# Set our module list to anything in `com.powershellgallery.modules`
$moduleList = $script:Cache['com.powershellgallery.modules']

# Sort our modules by download count.
# The point here is we can _resort_ our objects any way we want.
$moduleList = @($moduleList | Sort-Object -Property DownloadCount -Descending)

# Extend our type and add a ToString method.

# If we are rendering custom objects, adding `ToString` will make this object stringify however we would like
Update-TypeData -TypeName com.powershellgallery.module -Force -MemberType ScriptMethod -MemberName ToString -Value {
    param()

    # Let's start by preparing our data attributes.
    # This defines what we can use to sort the object.
    $attributes = [Ordered]@{
        'class' = 'powershell-gallery-module'
        'data-module-name'        = $this.id
        'data-module-downloads'   = $this.downloadCount
        'data-module-published'   = $this.published
        'data-module-last-updated'= $this.lastUpdated
    }    

    # Combine our attributes
    $attributeString = @(
        $attributes.GetEnumerator() | 
        ForEach-Object { "$($_.Key)='$($_.Value)'"
    }) -join ' '

    # We want to output a single string
    # so collect all output into an array
    @(
        # start off by declaring an article element
        "<article $attributeString>"

            # Within it, let's start with the identifier
            "<h2>"
                if ($this.ProjectUrl) {
                    "<a href='$($this.ProjectUrl)'>$($this.id)</a>"
                } else {
                    $this.id
                }
            "</h2>"                

            # Next up, let's include the version
            "<h3>v$($this.Version)</h3>"                        
            
            # Include the description
            "<h4>$([Web.HttpUtility]::HtmlEncode($this.Description))</h4>"

            # Now include the module downloads badge.
            "<a href='https://www.powershellgallery.com/packages/$($this.Id)/' >"
                "<img src='https://img.shields.io/powershellgallery/dt/$($this.Id)' alt='$(
                    $this.downloadCount # and use the download count as our alt text
                )' />"
            "</a>"

            # Last but not least, lets include some expandable details
            "<details>"            
            
            "<summary>Details</summary>"

            # The details will be included in a table
            "<table>"                
                # We'll start with any string properties we want to display
                foreach($propertyName in 'DownloadCount') {
                    "<tr>"
                        "<th>$propertyName</th>"
                        "<td>$([Web.HttpUtility]::HtmlEncode($this.$propertyName))</td>"
                    "</tr>"
                }

                # and then show any `<time>` properties we want to display.
                foreach($propertyName in 'Published', 'Created', 'LastUpdated') {
                    "<tr>"
                        "<th>$propertyName</th>"
                        "<td><time>$(
                            # using the semantically correct format.
                            $this.$propertyName.ToString('yyyy-MM-dd')
                        )</time></td>"
                    "</tr>"
                }                
            "</table>"
            "</details>"            
        "</article>"
    ) -join [Environment]::NewLine 
    # We join all content together by newlines, and now we have web view.
}


<#

Now we want to take our objects and render them in the page.

We'll declare things in the "correct" order:

* CSS
* HTML
* JavaScript

By putting CSS first, we prevent flashes of unstyled content (FOUCs)

(because we style elements before they appear)

By putting HTML second, we ensure elements are loaded into the document tree.

(before JavaScript needs to find them)

By putting JavaScript last, both styles and elements are already ready

(so our JavaScript does not have to wait)

#>

#region css
"<style>"
@(
# Center headers
"h1 {text-align: center;}"

# Align tables within powershell-gallery-modules
"
.powershell-gallery-module th {
    text-align: left;
}

.powershell-gallery-module td {
    text-align: right;
}
"

# Make the modules grid
"
.powershell-gallery-modules {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 2.5em;
    margin: 2.5em
}
"

# Display the total

"
.powershell-gallery-total { 
    font-size: 1.75rem; 
    text-align: center; 
    margin-bottom: 0.5em;
}
"

# Style the sorter

"
.powershell-gallery-sort {
    font-size: 1.5em;
    text-align: center;
}
"
)
"</style>"

#endregion css

#region html

# Add the header

"<h1>My PowerShell Modules</h1>"

# If we are not hiding the gallery total
if (-not $HideGalleryTotal) {
    # add it up and display it.
    "<div class='powershell-gallery-total'>"
        "Total Modules: $("{0:N0}" -f ($moduleList.Count))",        
            "Total Downloads: $("{0:N0}" -f ($moduleList |
                Measure-Object -Property DownloadCount -Sum |
                Select-Object -ExpandProperty Sum
            ))" -join '<br/>'
    "</div>"
}

# Then add the repo sorter

#region Repo Sorter
"
<div class='powershell-gallery-sort'>
Sort by:
<select id='sort-modules'>
    <option value='random'>Random</option>
    <option value='moduleDownloads' selected>Downloads</option>
    <option value='modulePublished'>Published</option>    
    <option value='moduleName'>Name</option>    
</select>
</div>
"
#endregion Repo Sorter

#region Module List
"<div class='powershell-gallery-modules'>"
$moduleList -join [Environment]::NewLine
"</div>"
#endregion Module List

#region View Source
"<details><summary>View Source</summary>"
"<pre><code class='language-powershell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</details>"
#endregion View Source

#region javascript
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
        } else if (sortBy === 'moduleLastUpdated') {
            return new Date(b.dataset.moduleLastUpdated) - new Date(a.dataset.moduleLastUpdated)
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

#endregion javascript

if ($site.Includes.CopyCode) {
    . $site.Includes.CopyCode
}

if ($psScriptRoot) { Pop-Location }

