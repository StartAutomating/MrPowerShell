<#
.SYNOPSIS
    Tricks
.DESCRIPTION
    Tricks of the Trade.
.NOTES
    Want to learn a trick?  I may have a few to share.

    This folder contains some tricks of the trade I've figured out over the years.
.LINK 
    https://MrPowerShell.com/Tricks     
.LINK
    https://MrPowerShell.com/Gists
.LINK
    https://MrPowerShell.com/GitHub
.LINK
    https://MrPowerShell.com/Modules
#>

#region Page Help
# Get my help
$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File

# My synopsis becomes the page title
$title = $myHelp.Synopsis
# and my description becomes the page description.
$description = $myHelp.Description.text -join [Environment]::NewLine
# My notes are in markdown.
$notes = $myHelp.alertset.alert.text -join [Environment]::NewLine

# If we have page metadata, copy title and description
if ($page -is [Collections.IDictionary]) {
    $page.Title = $title
    $page.Description = $description
}

# Make one big markdown out of our title, description, and notes
@"
# $($title)

## $($description)

$notes
"@ | 
    # convert it from markdown
    ConvertFrom-Markdown |
    # and output the HTML
    Select-Object -ExpandProperty Html
#endregion Page Help

#region Local Links
"<ul>"
foreach ($file in Get-ChildItem -Filter *.html.ps1) {    
    $fileName = $file.Name -replace '\.html\.ps1$'
    if ($fileName -eq 'index') { continue }
    "<li><a href='$fileName'>"
    $([Web.HttpUtility]::HtmlEncode(
        ($fileName -replace '-', ' ')
    ))
    "</a></li>"
}
"</ul>"
#endregion Local Links

#region Page Links
$myFile = Get-Item -LiteralPath $MyInvocation.MyCommand.ScriptBlock.File

$selfReference = @(    
    if ($myFile.Name -eq 'index.html.ps1') {
        $myFile.Directory.Name
    } else {
        $myFile.Name -replace '\.html\.ps1$'
    }   
)


$relatedLinks = foreach ($link in $myHelp.relatedLinks.navigationLink.uri) {
    $linkUri = $link -as [uri]
    if ($linkUri.IsAbsoluteUri -and
        ($linkUri.Segments[-1] -replace '/') -ne $selfReference
    ) {
        $linkUri
    }    
}

if ($relatedLinks) {
    "<hr/>"
    "<h4>Related</h4>"
    "<ul>"
    foreach ($link in $relatedLinks) {
        "<li><a href='$link'>$(
            [Web.HttpUtility]::HtmlEncode(
                $link.Segments[-1] -replace '/'
            )
        )</a></li>"
    }
    "</ul>"
}
#endregion Page Links

#region View Source
"<hr/>"
"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"
#endregion View Source
