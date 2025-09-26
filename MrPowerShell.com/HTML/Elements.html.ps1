<#
.SYNOPSIS
    HTML Elements
.DESCRIPTION
    HTML Elements Cheat Sheet
.NOTES
    It's nice to have a handy reference of HTML elements.

    I'd highly recommend using the [Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/).

    In case you ever want to get all of the elements in a PowerShell script, this page shows you how.

    It extracts all of the reference links and outputs them into a handy table and a json file.
.LINK
    https://MrPowerShel.com/HTML/Elements
.LINK
    https://MrPowerShel.com/HTML/Elements.json
.LINK
    https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/
.EXAMPLE
    ./Elements.html.ps1 | ../layout.ps1 > ./Elements.html
#>
param()

if ($PSScriptRoot) { Push-Location $PSScriptRoot }
$myHelp = Get-Help $myInvocation.MyCommand.ScriptBlock.File

if ($page -is [Collections.IDictionary]) {
    $page.Title = $title = $myHelp.Synopsis
    $page.Description = $description = $myHelp.description.text -join [Environment]::NewLine
}
$myNotes = $myHelp.alertSet.alert.text
if ($myNotes) {
    (ConvertFrom-Markdown -InputObject $myNotes).Html
}

"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</details>"

$elementRoot = "https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements"
if (-not $script:HtmlElementList) {
    $script:HtmlElementList = Invoke-WebRequest $elementRoot |
        ForEach-Object { $_.Links } |    
        Where-Object Href -match '/HTML/Reference/Elements' |
        ForEach-Object { ($_.OuterHtml -as [xml]).a.code } |
        Select-Object -Unique |
        Sort-Object |
        Select-Object @{
            Name='Name'
            Expression={"$_" -replace '[<>]'}
        }, @{
            Name='Href'
            Expression={$elementRoot, ("$_" -replace '[<>]' -replace '\stype="','/' -replace '"$') -join '/'}
        }
}

"<style>"
".element-list { width: 80vh;margin-left:auto;margin-right:auto; }"
"</style>"
"<div class='element-list'>"
ConvertFrom-Markdown -InputObject (    
    @(foreach ($element in $script:HtmlElementList) {
        "* [$($element.Name)]($($element.Href))"
    }) -join [Environment]::NewLine
) | 
    Select-Object -ExpandProperty Html
"</div>"
$script:HtmlElementList | ConvertTo-Json -Depth 3 | Set-Content ./Elements.json

ConvertFrom-Markdown -InputObject @"
To download this list, run:

~~~PowerShell
Invoke-RestMethod https://MrPowerShell.com/HTML/Elements.json
~~~

Or use this [link](https://MrPowerShell.com/HTML/Elements.json)
"@
 |
    Select-Object -ExpandProperty HTML
if ($PSScriptRoot) { Pop-Location}