<#
.SYNOPSIS
    The Blue Sky Butterfly Breakdown
.DESCRIPTION
    Breaking down the Blue Sky Butterfly logo.

    The Blue Sky Butterfly logo is quite nice.  
    
    Breaking down how it's constructed is a great way to learn about scalable vector graphics.
.NOTES
    ### The Basics 

    BlueSky has a beautiful butterfly logo that can teach us all a lot about [scalable vector graphics](https://developer.mozilla.org/en-US/docs/Web/SVG/).

    The BlueSky butterfly is expressed as a single [SVG path](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorials/SVG_from_scratch/Paths).

    It's made out of 16 steps.
    
    Almost all of these are [Cubic Bezier Curves](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorials/SVG_from_scratch/Paths#b%C3%A9zier_curves).

    Most of these curves are relative to the current position, which I honestly did not know was possible!

    Let's dissect this butterfly and see how it works.

    ### Dissecting SVG paths

    SVG paths often look pretty cryptic.

    To figure out what one does, we can dissect the SVG step by step.

    Each new set of steps will start with a letter and any number of digits.

    We can split up the path by letter, and see what each adds to the shape.

    #### Dissecting with PowerShell and Regular Expressions

    If we wanted to use some regex to do this, we can lookahead `(?=...)` for a letter `\p{L}`

    ~~~regex
    (?=\p{L})
    ~~~

    Since PowerShell has a handy `-split` operator, we can use this to break apart the path
    
    Here's a quick PowerShell example:

    ~~~PowerShell
    'm 0 0 l 42 0 l 0 42 l -42 0 l 0 -42' -split '(?=\p{L})' -ne ''
    ~~~

    We can use this approach to break up any path and rejoin it into any number of smaller paths.

    We can then [animate the path](https://developer.mozilla.org/en-US/docs/Web/SVG/Reference/Element/animate) to show it step by step.
    
    ### The BlueSky Butterfly

    The BlueSky Butterfly is made up of 16 steps, most of them curves.

    Here's the annotated sequence, in a PowerShell data block

    ~~~PowerShell
    {{$annotatedSequence}}
    ~~~

    Let's see the whole shape:

    {{$SVG}}

    And the script that made it:
    
    {{$function:BlueSkyButterfly}}
    
    And let's see a step-by-step animation:

    {{$Animation}}

    And the script that made it:

    {{$function:BlueSkyButterflyAnimation}}

    Hopefully this helps us all understand a bit more about SVG.

    We can dissect any shape from it's path.

    And we make stop-motion animation just by providing lots of paths.

    Have Fun!
.LINK
    https://MrPowerShell.com/SVG/BlueSkyButterfly
#>
param()

Push-Location $PSScriptRoot

# Declare a data block with the annotated sequence

$annotatedSequence = {
    data {
        'M180 142' # Start at the center of the butterfly (along the top edge)
        'c-16.3 -31.7 -60.7 -90.8 -102 -120' # left wing curve
        'C38.5 -5.9 23.4-1 13.5 3.4' # upper wing top tip
        '2.1 8.6 0 26.2 0 36.5' # upper wing left tip
        'c 0 10.4 5.7 84.8 9.4 97.2' # upper left wing
        '12.2 41 55.7 55 95.7 50.5' # upper left wing inward curve
        '-58.7 8.6 -110.8 30 -42.4 106.1' # lower left outward curve
        '75.1 77.9 103 -16.7 117.3 -64.6' # lower left inward curve
        '14.3 48 30.8 139 116 64.6' # lower right inward curve
        '64 -64.6 17.6 -97.5 -41.1 -106.1' # lower right outward curve
        '40 4.4 83.5 -9.5 95.7 -50.5' # upper right outward curve
        '3.7 -12.4 9.4 -86.8 9.4 -97.2' # upper right side curve
        '0 -10.3 -2 -27.9 -13.5 -33' # upper right top tip
        'C336.5-1 321.5-6 282 22' # upper right top edge 
        'c-41.3 29.2-85.7 88.3-102 120' # upper right inward curve
        'Z'
    }    
}

# To get our steps, we simply run the data block
function BlueSkyButterfly {
$sequenceSteps = @(. $annotatedSequence)

# To make that into SVG, we just put that sequence into a path.
$svg = @"
<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" viewBox="0 0 360 320" class="foreground-stroke">    
    <path fill="#0085ff" stroke='#0085ff' d="$sequenceSteps" />    
</svg>
"@
$svg
}

function BlueSkyButterflyAnimation {
$sequenceSteps = @(. $annotatedSequence)
# To make the construction animation, we need to show each set of steps
$constructionAnimation = @(
    # so we iterate thru starting at the 2nd step
    foreach ($n in 1..$sequenceSteps.Count) {
        # and get all the steps between the start and our index
        $sequenceSteps[0..$n] -join ' '
    }
) -join (';' + [Environment]::NewLine) # and join them all by semicolons.


$animation = @"
<svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%">
    <svg viewBox="0 0 360 320" class="foreground-stroke">
        <path fill="#0085ff" stroke='#0085ff'>
            <animate attributeName='d' values='$constructionAnimation' dur='4.2s' repeatCount='indefinite' attributeType='XML' />
        </path>
    </svg>
</svg>
"@
$animation
}

. BlueSkyButterfly > ./BlueSkyButterfly.svg
. BlueSkyButterflyAnimation > ./BlueSkyButterflyAnimated.svg

#region Get-Help

# We can imagine most pages as their help (rendered as markdown)
$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File

# The synopsis becomes the title
$title = $myHelp.Synopsis
# The description stays the description
$description = $myHelp.Description.text -join [Environment]::NewLine
# and the notes become the main page body.
$notes = $myHelp.alertSet.alert.text -join [Environment]::NewLine 

# If page is a dictionary, let's set some keys (so metadata propagates)
if ($page -is [Collections.IDictionary]) {
    $page.Title = $title
    $page.Description = $description
}

# Convert the help from markdown
ConvertFrom-Markdown -InputObject (
    @(
        "# $Title"
        "## $Description"
        $notes
    ) -join [Environment]::NewLine -replace 
        '\{\{(?<m>.+?)\}\}', {
            # and replace variables without handlebars
            $m = $_.Groups['m'].Value -replace '^\$'
            if ($m -match '(?>Key|Token|Password)$') { return '' }
            if ($m -match '^function:') {
                return @(
                    "~~~PowerShell"
                    "function $($m -replace '^function:') {"
                    $ExecutionContext.SessionState.InvokeProvider.Item.Get($m).ScriptBlock
                    "}"
                    "~~~"
                ) -join [Environment]::NewLine
            } else {
                return $ExecutionContext.SessionState.PSVariable.Get($m).Value
            }            
        }
) |
    Select-Object -ExpandProperty HTML
#endregion Get-Help

#region View Source
"<details><summary>View Source</summary><pre><code class='language-powershell'>"
$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))
"</code></pre></details>"
#endregion View Source

Pop-Location    