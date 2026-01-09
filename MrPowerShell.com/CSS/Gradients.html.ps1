<#
.SYNOPSIS
    CSS Gradients
.DESCRIPTION
    Generating CSS Gradients
.NOTES
    CSS Gradients are pretty great.

    I recently wrote [Gradient](https://github.com/PowerShellWeb/Gradient): a mini-module to help generate gradients.

    This is a collection of some of the cool CSS gradients you can generate.
.LINK
    https://MrPowerShell.com/CSS/Gradients # CSS Gradients
#>
#requires -Module MarkX, Gradient
param(
[Collections.IDictionary]
$SampleGradients = [Ordered]@{
    radial = { gradient '#4488ff' '#224488' }
    linear = { gradient linear '#4488ff' '#224488' }
    conic =  { gradient conic '#4488ff' '#224488' }
    diagonalRepeating = { gradient repeating-linear '45deg', 
        '#4488ff', 
        '#4488ff 5px',
        '#224488 5px', 
        '#224488 30px'
    }
    radialRepeating = { gradient repeating-radial '#4488ff', 
        '#4488ff 5px',
        '#224488 5px', 
        '#224488 30px'
    }
    conicRepeating = { gradient repeating-conic '#4488ff 0% 5%',
        '#224488 5% 10%'
    }
    conicRepeatingOverlap = @(
        { gradient repeating-conic 'from 0deg at 25% 50%',
                '#4488ff99 0% 5%',
                '#22448899 5% 10%'
        }, { gradient repeating-conic 'from 180deg at 75% 50%',
            '#4488ff99 0% 5%',
            '#22448899 5% 10%'
        }
    )
    conicRepeatingFromCorners = @(
            { gradient repeating-conic 'from 0deg at 0% 0%',
                '#4488ff99 0% 2.5%',
                '#22448899 2.5% 5%'
        }, { gradient repeating-conic 'from 180deg at 100% 0%',
            '#4488ff99 0% 2.5%',
            '#22448899 2.5% 5%'
        }
    )
    conicRepeatingVariable = { gradient repeating-conic 'var(--blue) 0% 5%',
        'var(--brightBlue) 5% 10%'
    }
    conicRepeatingColorMix = { 
        gradient repeating-conic 'color-mix(in srgb, var(--blue) 50%, transparent) 0% 5%',
            'color-mix(in srgb, var(--brightBlue) 50%, transparent) 5% 10%'
    }
    conicRepeatingVariableOverlap = @(
        { gradient repeating-conic 'from 0deg at 25% 50%',
                'color-mix(in srgb, var(--blue) 50%, transparent) 0% 5%',
                'color-mix(in srgb, var(--brightBlue) 50%, transparent) 5% 10%'
        }, 
        { gradient repeating-conic 'from 180deg at 75% 50%',
            'color-mix(in srgb, var(--blue) 50%, transparent) 0% 5%',
            'color-mix(in srgb, var(--brightBlue) 50%, transparent) 5% 10%'
        }
    )
    conicRepeatingVariableCorners = @(
        { gradient repeating-conic 'from 0deg at 0% 0%',
                'color-mix(in srgb, var(--blue) 50%, transparent) 0% 5%',
                'color-mix(in srgb, var(--brightBlue) 50%, transparent) 5% 10%'
        }, 
        { gradient repeating-conic 'from 180deg at 100% 0%',
            'color-mix(in srgb, var(--blue) 50%, transparent) 0% 5%',
            'color-mix(in srgb, var(--brightBlue) 50%, transparent) 5% 10%'
        }        
    )
    conicRepeatingVariableFourCorners = @(
        { gradient repeating-conic 'from 0deg at 0% 0%',
                'color-mix(in srgb, var(--blue) 25%, transparent) 0% 5%',
                'color-mix(in srgb, var(--brightBlue) 25%, transparent) 5% 10%'
        }, 
        { gradient repeating-conic 'from 180deg at 100% 0%',
            'color-mix(in srgb, var(--blue) 25%, transparent) 0% 5%',
            'color-mix(in srgb, var(--brightBlue) 25%, transparent) 5% 10%'
        },
        { gradient repeating-conic 'from 0deg at 0% 100%',
                'color-mix(in srgb, var(--blue) 25%, transparent) 0% 5%',
                'color-mix(in srgb, var(--brightBlue) 25%, transparent) 5% 10%'
        },
        { gradient repeating-conic 'from 180deg at 100% 100%',
            'color-mix(in srgb, var(--blue) 25%, transparent) 0% 5%',
            'color-mix(in srgb, var(--brightBlue) 25%, transparent) 5% 10%'
        }
    )
}
)

#region Article
$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File
$title = $myHelp.Synopsis
$description = $myHelp.description.text -join [Environment]::NewLine

if ($page -isnot [Collections.IDictionary]) {
    $page = [Ordered]@{}
}

$page.title = $title
$page.description = $description

$markdown = $myHelp.alertset.alert.text -join [Environment]::NewLine 

$markdown > ($MyInvocation.MyCommand.Name -replace '(?:\.html)?\.ps1$', '.md')
"<style>"
"article { width: 120ch; margin-left:auto;margin-right:auto; }"
"article img { display: block; width: 50%; margin-left: auto; margin-right:auto; }"
"</style>"
"<article>"
$markdown | 
    ConvertFrom-Markdown | 
    Select-Object -expand html
"</article>"
#endregion Article

foreach ($sampleId in @($SampleGradients.Keys)) {
    if ($SampleGradients[$sampleId] -as [ScriptBlock[]]) {
        "<div>"
            "<h3>$sampleId</h3>"        
            "<div id='$sampleId' style='width:100%;height:100%;background:$(
                @(foreach ($gradient in $SampleGradients[$sampleId]) {
                    . $gradient
                }) -join ', '
            )'></div>"
        "</div>"
    }
}

if ($site.Includes.SelectPalette) {
    . $site.Includes.SelectPalette
}

if ($site.Includes.GetRandomPalette) {
    . $site.Includes.GetRandomPalette
}

#region View Source
"<details><summary>View Source</summary>"
"<pre><code class='language-powershell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</details>"
#endregion View Source

if ($site.Includes.CopyCode) {
    . $site.Includes.CopyCode
}

