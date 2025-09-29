<#
.SYNOPSIS
    MathML Elements
.DESCRIPTION
    MathML Elements Cheat Sheet
.NOTES
    It's nice to have a handy reference of MathML elements.

    I'd highly recommend using the [Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/MathML/Reference/Elements/).

    In case you ever want to get all of the elements in a PowerShell script, this page shows you how.

    It extracts all of the reference links and outputs them into a handy table and a json file.
.LINK
    https://MrPowerShel.com/MathML/Elements
.LINK
    https://developer.mozilla.org/en-US/docs/Web/MathML/Reference/Element
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

$elementRoot = "https://developer.mozilla.org/en-US/docs/Web/MathML/Reference/Element"

if (-not $script:MathMLElementList) {
    $script:MathMLElementList = Invoke-WebRequest $elementRoot |
        ForEach-Object { $_.Links } |    
        Where-Object Href -match '/MathML/Reference/Element' |
        ForEach-Object { ($_.OuterHtml -as [xml]).a.code } |
        Select-Object -Unique |
        Sort-Object |
        Select-Object @{
            Name='name'
            Expression={"$_" -replace '[<>]'}
        }, @{
            Name='href'
            Expression={$elementRoot, ("$_" -replace '[<>]' -replace '\stype="','/' -replace '"$') -join '/'}
        }
}

"<style>"
".element-list { width: 80vh;margin-left:auto;margin-right:auto; }"
"</style>"
"<div class='element-list'>"
ConvertFrom-Markdown -InputObject (    
    @(foreach ($element in $script:MathMLElementList) {
        "* [$($element.Name)]($($element.Href))"
    }) -join [Environment]::NewLine
) | 
    Select-Object -ExpandProperty Html
"</div>"
$script:MathMLElementList | ConvertTo-Json -Depth 3 | Set-Content ./Elements.json
ConvertFrom-Markdown -InputObject @"
To download this list, run:

~~~PowerShell
Invoke-RestMethod https://MrPowerShell.com/MathML/Elements.json
~~~

Or use this [link](https://MrPowerShell.com/MathML/Elements.json)
"@
 |
    Select-Object -ExpandProperty Html
if ($PSScriptRoot) { Pop-Location}
