<#
.SYNOPSIS
    Turtle in PowerShell
.DESCRIPTION
    Scripting SVGs with Turtle in PowerShell.
.NOTES
    Turtle graphics are pretty groovy.
    
    They've been kicking it since 1966, with the first implementations of the Logo language.

    At their most basic, Turtle graphics consist of two operations:

    * Move Forward
    * Rotate

    For bonus points, most turtle implementations let you raise or lower a pen.

    Once it clicked that Turtle graphics are "that easy",

    I though I would have a little fun by implementing a Turtle graphics engine in PowerShell.

    You can check it out on [GitHub](https://github.com/PowerShellWeb/Turtle)

    This page shows off a few shapes turtle can make.
.LINK
    https://MrPowershell.com/SVG/Turtle
.LINK
    https://github.com/PowerShellWeb/Turtle
.EXAMPLE
    ./Turtle.html.ps1 > ./Turtle.html
.EXAMPLE
    ./Turtle.html.ps1 | > ./Turtle.html
#>

#requires -Module Turtle
param()

$myHelp = Get-Help $myInvocation.MyCommand.ScriptBlock.File


if ($page -is [Collections.IDictionary]) {
    $page.Title = $title = $myHelp.Synopsis
    $page.Description = $description = $myHelp.description.text -join [Environment]::NewLine
    $myNotes = $myHelp.alertSet.alert.text
    if ($myNotes) {
        (ConvertFrom-Markdown -InputObject $myNotes).Html
    }
}
"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</details>"


"<h3>Random Flower</h3>"

Turtle Flower 50 10 (4..6 | Get-Random) 36 | 
    Select-Object -ExpandProperty Symbol | 
    Select-Object -ExpandProperty OuterXML

"<h3>Koch Snowflake</h3>"

Turtle KochSnowflake 10 4 |
    Select-Object -ExpandProperty Symbol | 
    Select-Object -ExpandProperty OuterXML

"<h3>Moore Curve</h3>"

Turtle MooreCurve 10 4 |
    Select-Object -ExpandProperty Symbol | 
    Select-Object -ExpandProperty OuterXML


"<h3>Sierpinski Triangle</h3>"

Turtle SierpinskiTriangle 10 4 |
    Select-Object -ExpandProperty Symbol | 
    Select-Object -ExpandProperty OuterXML