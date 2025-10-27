<#
.SYNOPSIS
    Tricks
.DESCRIPTION
    Tools and tricks of technical tradecraft.
.NOTES
    Want to learn a trick?  I may have a few to share.

    This folder contains some tricks of the trade I've figured out over the years.
#>
$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File
$title = $myHelp.Synopsis
$description = $myHelp.Description.text -join [Environment]::NewLine
$notes = $myHelp.alertset.alert.text -join [Environment]::NewLine

@(
    "# $Title"  
    "## $Description"
    $Notes
) | ConvertFrom-Markdown | Select-Object -ExpandProperty HTML

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


"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"
