<#
.SYNOPSIS
    SVG Mountain Range
.DESCRIPTION
    SVG Mountain Range Generator
.NOTES
    SVG paths are incredibly powerful.

    One of their little tricks is that ability to use relative paths, instead of absolute points.

    You do this by using the lowercase version of any path command.

    For example:

    `l+5,-5` means "draw a line to 5 pixels right and 5 pixels down from the current point."
    
    We can use this to create a mountain range by drawing a series of lines that go up and down randomly.

    This script is an example of the technique in action.

    Every time the site rebuilds, it will generate a new mountain range.
#>
param(
    # The mountain range width.
    [int]
    $MountainRangeWidth = 400,

    # The mountain range height.
    [int]
    $MountainRangeHeight = 400,

    # The number of steps in the mountain range.
    [int]
    $MountainRangeSteps = 100,

    # The seed for the random number generator.
    # This allows you to generate the same mountain range every time.
    [int]
    $MountainRangeSeed = 0,

    # The number of layers in the mountain range.
    # Each layer is a series of lines that go up and down randomly.
    [int]
    $MountainRangeLayerCount = 2
)

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

if ($MountainRangeSeed) {
    $null = Get-Random -SetSeed $MountainRangeSeed
}

$MountainRangeSlope = $MountainRangeWidth * 3 / $MountainRangeSteps 

$rangeLayers = @(
    foreach ($layerNumber in 1..$MountainRangeLayerCount) {     
        ,@(foreach ($n in 1..$MountainRangeSteps) {
            "l+$MountainRangeSlope $('+','-' | Get-Random)$mountainRangeSlope"
        })
    }    
)


[Array]::Reverse($rangeLayers)

@"
<svg width="100%" height="100%">
$(
    foreach ($rangeLayer in $rangeLayers) {
        "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 $MountainRangeWidth $MountainRangeHeight' class='foreground-stroke'>"
            "<path fill='transparent' d='M-$MountainRangeWidth $($MountainRangeHeight / 2) $($rangeLayer)' />"
        "</svg>"
    }
)    
</svg>
"@