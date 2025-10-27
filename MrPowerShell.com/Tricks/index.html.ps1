<#
.SYNOPSIS
    Tricks
.DESCRIPTION
    Tricks of the Trade.
.NOTES
    Want to learn a trick?  I may have a few to share.

    This folder contains some tricks of the trade I've figured out over the years.

    You may also want to check out:
    
    * [My Gists](https://MrPowerShell.com/Gists)
    * [My GitHub Repos](https://MrPowerShell.com/GitHub)
    * [My Modules](https://MrPowerShell.com/Modules)
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

#region View Source
"<hr/>"
"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"
#endregion View Source
