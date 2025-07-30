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

    You can check it out on [GitHub](https://github.com/PowerShellWeb/Turtle).

    You can download and install Turtle from the [PowerShell Gallery](https://www.powershellgallery.com/packages/Turtle).

    This implementation of Turtle graphics goes a bit above and beyond by allowing you to create SVGs from any [L-system](https://en.wikipedia.org/wiki/L-system).

    Check out some of the built-in beautiful graphics!
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

#region Get Metadata From Help
$myHelp = Get-Help $myInvocation.MyCommand.ScriptBlock.File

if ($page -is [Collections.IDictionary]) {
    $page.Title = $title = $myHelp.Synopsis
    $page.Description = $description = $myHelp.description.text -join [Environment]::NewLine
}
#endregion Get Metadata From Help

if ($page -is [Collections.IDictionary]) {
    $Page.Image = "https://MrPowerShell.com/SVG/Turtle.png"
}

#region Display Notes
$myNotes = $myHelp.alertSet.alert.text
if ($myNotes) {
    (ConvertFrom-Markdown -InputObject $myNotes).Html
}
#endregion Display Notes

#region View Source
"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</details>"
#endregion View Source

#region Grid Styles
"<style>"
".turtle-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(500px, 1fr)); gap: 2.5em; margin: 2.5em}"
".turtle-name { text-align: center; }"
"</style>"
#endregion Grid Styles


$turtles = [Ordered]@{
    "Random Flower" = turtle Flower 50 10 (4..6 | Get-Random) 36
    "Box Fractal" = turtle BoxFractal 10 4
    "Binary Tree" = turtle BinaryTree 10 4   
    "Fractal Plant" = turtle FractalPlant 10 4
    "Koch Island" = Turtle KochIsland 10 4
    "Koch Snowflake" = Turtle KochSnowflake 10 4    
    "Hilbert Curve" = turtle HilbertCurve 10 4
    "Moore Curve" = Turtle MooreCurve 10 4
    "Peano Curve" = Turtle PeanoCurve 10 4 
    "Sierpinski Arrowhead" = turtle SierpinskiArrowheadCurve 10 4
    "Sierpinski Square Curve" = turtle SierpinskiSquareCurve 10 4
    "Sierpinski Triangle" = Turtle SierpinskiTriangle 10 4    
    "Terdragon" = turtle TerdragonCurve 10 4
    "Twin Dragon" = turtle TwinDragonCurve 10 4
}

"<div class='turtle-grid'>"
foreach ($turtleName in $turtles.Keys) {
    "<div>"
        "<h3 class='turtle-name'>$turtleName</h3>"
        "<div>"
            "$($turtles[$turtleName])"
        "</div>"                
    "</div>"
}
"</div>"
return
