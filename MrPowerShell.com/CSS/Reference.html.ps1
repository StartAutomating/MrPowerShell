<#
.SYNOPSIS
    CSS reference
.DESCRIPTION
    CSS Reference Cheat Sheet
.NOTES    
    It's nice to have a handy reference for CSS.

    I'd highly recommend using the [Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Elements/).

    In case you ever wanted a scriptable reference for CSS, this page shows you how.

    It extracts all of the reference links and outputs them into some handy table and a json file.
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


if (-not $script:CssLinks) {
    $script:CssLinks = Invoke-WebRequest https://developer.mozilla.org/en-US/docs/Web/CSS/ |
        Select-Object -ExpandProperty Links |
        Where-Object Href -match '/CSS' |
        ForEach-Object {
            $link = $_        
            $linkText = ($_.outerhtml -as [xml]).a.innerText
            [PSCustomObject]@{
                name = $linkText
                href = $link = "https://developer.mozilla.org" + $link.href
            }    
        } | 
        Sort-Object Name    
}

$cssReferenceLinks = [Ordered]@{
    'atRules' =
        $script:CssLinks | 
            Where-Object Name -match '^\@'
    'attributes' =
        $script:CssLinks |
            Where-Object Name -cmatch '^[\p{Ll}\-]+$' |
            Where-Object Href -match '/CSS/[^/]+$'
    'combinators' =
        $script:CssLinks |
            Where-Object Name -match '(?>Combinator|Selector List)' |
            Where-Object Href -match '/CSS/[^/]+$'
    'functions' =
        $script:CssLinks | 
            Where-Object Name -match '\(\)$' |
            Where-Object Name -NotMatch '^:' 
    'pseudoClasses' =
        $script:CssLinks | 
            Where-Object Name -match '^:' |
            Where-Object Name -NotMatch '^::'
    'pseudoElements' = 
        $script:CssLinks | 
            Where-Object Name -match '^::'
    'selectors' = 
        $script:CssLinks |             
            Where-Object Name -match 'Selector' |
            Where-Object Name -notmatch 'Selector List' |
            Where-Object Name -notmatch '^\p{P}' |
            Where-Object Href -match '/CSS/[^/]+$'
    'types' = 
        $script:CssLinks | 
            Where-Object Name -match '^<.+?>$'
}

ConvertFrom-Markdown -InputObject (
    @(foreach ($referenceTopic in $cssReferenceLinks.Keys) {
        "* $referenceTopic"
        foreach ($referenceLink in $cssReferenceLinks[$referenceTopic]) {
            "  * [``$($referenceLink.Name)``]($($referenceLink.Href))"
        }
    }) -join [Environment]::NewLine
) |
    Select-Object -ExpandProperty Html

$cssReferenceLinks |
    ConvertTo-Json -Depth 4 > ./Reference.json

ConvertFrom-Markdown -InputObject @"
To download this list, run:

~~~PowerShell
Invoke-RestMethod https://MrPowerShell.com/CSS/Reference.json
~~~

Or use this [link](https://MrPowerShell.com/CSS/Reference.json)
"@
 |
    Select-Object -ExpandProperty HTML
    
if ($PSScriptRoot) { Pop-Location }