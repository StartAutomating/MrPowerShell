<#
.SYNOPSIS
    CSS Gradients
.DESCRIPTION
    Generating CSS Gradients
.NOTES
    CSS Gradients are pretty great.

    I recently wrote [Gradient](https://github.com/PowerShellWeb/Gradient), a mini-module to help generate gradients.

    This page generates a number of cool CSS gradients we can drop into any website.

    Like most of the rest of this site, this page is experimental and subject to change.

    This work will be feeding into a framework, once I Have the excess time.
.LINK
    https://MrPowerShell.com/CSS/Gradients
#>
#requires -Module MarkX, Gradient
param(
[Collections.IDictionary]
$SampleGradients = [Ordered]@{
    radial = { gradient '#4488ff' '#224488' }
    radialRainbow = { gradient red orange yellow green blue indigo violet }
    radialVariableRainbow = { gradient @(
        'var(--red)'
        'var(--brightYellow)'
        'var(--yellow)'
        'var(--green)'
        'var(--blue)'
        'var(--brightPurple)'
        'var(--purple)'
    ) }
    linear = { gradient linear '#4488ff' '#224488' }
    linearVariable = { gradient linear 'var(--blue)' 'var(--brightBlue)' }
    linearVariableRainbow = { gradient linear @(
        'var(--red)'
        'var(--brightYellow)'
        'var(--yellow)'
        'var(--green)'
        'var(--blue)'
        'var(--brightPurple)'
        'var(--purple)'
    ) }
    conic =  { gradient conic '#4488ff' '#224488' }
    conicVariable = { gradient conic 'var(--blue)' 'var(--brightBlue)'}
    conicVariableRainbow = { 
        gradient conic @(
            'var(--red)'
            'var(--brightYellow)'
            'var(--yellow)'
            'var(--green)'
            'var(--blue)'
            'var(--brightPurple)'
            'var(--purple)'
        )
    }
    diagonalLinearRepeating = { 
        @(
            'repeating-linear'
            '45deg'
            '#4488ff 1rem'
            '#224488 2rem'
        ) | gradient 
        
    }
    radialRepeating = { gradient repeating-radial '#4488ff 1rem',
        '#224488 2rem'
    }
    radialRepeatingVariable = { gradient repeating-radial 'var(--blue) 1rem',         
        'var(--brightBlue) 2rem'
    }
    radialRepeatingRGBVariable = { gradient repeating-radial 'var(--red) 1rem',
        'var(--green) 2rem',
        'var(--blue) 3rem'    
    }
    radialRepeatingRGBVariableOverlap = @(
        { 
            gradient repeating-radial  @(
                'circle closest-side at 0.01% 0.01%'
                'color-mix(in srgb, var(--red) 50%, transparent) 1rem'
                'color-mix(in srgb, var(--green) 50%, transparent) 2rem'
                'color-mix(in srgb, var(--blue) 50%, transparent) 3rem'    
            )
        }
        { 
            gradient repeating-radial  @(
                'circle closest-side at 99.99% 0.01%'
                'color-mix(in srgb, var(--red) 50%, transparent) 1rem'
                'color-mix(in srgb, var(--green) 50%, transparent) 2rem'
                'color-mix(in srgb, var(--blue) 50%, transparent) 3rem'    
            )
        }
    )
    radialRepeatingRainbowVariableOverlap = @(
        { 
            gradient repeating-radial  @(
                'circle closest-side at 25% 50%'
                'color-mix(in srgb, var(--red) 50%, transparent) 1rem'
                'color-mix(in srgb, var(--brightYellow) 50%, transparent) 2rem'
                'color-mix(in srgb, var(--yellow) 50%, transparent) 3rem'
                'color-mix(in srgb, var(--green) 50%, transparent) 4rem'
                'color-mix(in srgb, var(--blue) 50%, transparent) 5rem'
                'color-mix(in srgb, var(--brightPurple) 50%, transparent) 6rem'
                'color-mix(in srgb, var(--purple) 50%, transparent) 7rem'
            )
        }
        { 
            gradient repeating-radial  @(
                'circle closest-side at 75% 50%'
                'color-mix(in srgb, var(--red) 50%, transparent) 1rem'
                'color-mix(in srgb, var(--brightYellow) 50%, transparent) 2rem'
                'color-mix(in srgb, var(--yellow) 50%, transparent) 3rem'
                'color-mix(in srgb, var(--green) 50%, transparent) 4rem'
                'color-mix(in srgb, var(--blue) 50%, transparent) 5rem'
                'color-mix(in srgb, var(--brightPurple) 50%, transparent) 6rem'
                'color-mix(in srgb, var(--purple) 50%, transparent) 7rem'
            )
        }
    )
    radialRepeatingRainbowVariableCorners = @(
        { 
            gradient repeating-radial  @(
                'circle closest-side at 0.01% 0.01%'
                'color-mix(in srgb, var(--red) 50%, transparent) 1rem'
                'color-mix(in srgb, var(--brightYellow) 50%, transparent) 2rem'
                'color-mix(in srgb, var(--yellow) 50%, transparent) 3rem'
                'color-mix(in srgb, var(--green) 50%, transparent) 4rem'
                'color-mix(in srgb, var(--blue) 50%, transparent) 5rem'
                'color-mix(in srgb, var(--brightPurple) 50%, transparent) 6rem'
                'color-mix(in srgb, var(--purple) 50%, transparent) 7rem'
            )
        }
        { 
            gradient repeating-radial  @(
                'circle closest-side at 99.99% 0.01%'
                'color-mix(in srgb, var(--red) 50%, transparent) 1rem'
                'color-mix(in srgb, var(--brightYellow) 50%, transparent) 2rem'
                'color-mix(in srgb, var(--yellow) 50%, transparent) 3rem'
                'color-mix(in srgb, var(--green) 50%, transparent) 4rem'
                'color-mix(in srgb, var(--blue) 50%, transparent) 5rem'
                'color-mix(in srgb, var(--brightPurple) 50%, transparent) 6rem'
                'color-mix(in srgb, var(--purple) 50%, transparent) 7rem'
            )
        }
    )
    radialEllipseRepeatingRainbowOverlap = @(
        {   
            $alpha = "$(100 / 2)%"
            @(foreach ($vertical in '50%') {
                foreach ($horizontal in '25%', '75%') {
                    gradient repeating-radial  @(
                        "ellipse 50% 50% at $Horizontal $vertical"
                        $colorNumber = 0
                        foreach ($color in 'red','brightYellow','yellow',
                            'green','blue','brightPurple', 'purple') {
                            $colorNumber++
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                        }
                    )
                }
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialCircleRepeatingForegroundBackgroundPentagon = @(
        {
            $alpha = "$([Math]::Round(100 / 5))%"
            $colors = 'foreground','background'
            $degrees = 0
            @(foreach ($position in '50% 0.01%','99.99% 50%','66% 99.99%', '33% 99.99%', '0.01% 50%') {                
                gradient repeating-radial  @(
                    "circle closest-side at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 72            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialCircleRepeatingForegroundBackgroundHexagon = @(
        {
            $alpha = "$([Math]::Round(100 / 5))%"
            $colors = 'foreground','background'
            $degrees = 0
            @(foreach ($position in '33% 0.01%','66% 0.01%','99.99% 50%','66% 99.99%', '33% 99.99%', '0.01% 50%') {                
                gradient repeating-radial  @(
                    "circle closest-side at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 60            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialEllipseRepeatingForegroundBackgroundHexagon = @(
        {
            $alpha = "$([Math]::Round(100 / 5))%"
            $colors = 'foreground','background'
            $degrees = 0
            @(foreach ($position in '33% 0.01%','66% 0.01%','99.99% 50%','66% 99.99%', '33% 99.99%', '0.01% 50%') {                
                gradient repeating-radial  @(
                    "ellipse 50% 50% at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 60            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialCircleRepeatingFullHexagon = @(
        {
            $alpha = "$([Math]::Round(100 / 5))%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            $degrees = 0
            @(foreach ($position in '33% 0.01%','66% 0.01%','99.99% 50%','66% 99.99%', '33% 99.99%', '0.01% 50%') {                
                gradient repeating-radial  @(
                    "circle closest-side at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 60            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialEllipseRepeatingRGBHexagon = @(
        {
            $alpha = "$([Math]::Round(100 / 5))%"
            $colors = 'red','green','blue'
            $degrees = 0
            @(foreach ($position in '33% 0.01%','66% 0.01%','99.99% 50%','66% 99.99%', '33% 99.99%', '0.01% 50%') {
                gradient repeating-radial  @(
                    "ellipse 50% 50% at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 72            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    
    radialEllipseRepeatingFullHexagon = @(
        {
            $alpha = "$([Math]::Round(100 / 5))%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            $degrees = 0
            @(foreach ($position in '33% 0.01%','66% 0.01%','99.99% 50%','66% 99.99%', '33% 99.99%', '0.01% 50%') {
                gradient repeating-radial  @(
                    "ellipse 50% 50% at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 60            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialEllipseRepeatingForegroundBackgroundPentagon = @(
        {
            $alpha = "$([Math]::Round(100 / 5))%"
            $colors = 'foreground','background'
            $degrees = 0
            @(foreach ($position in '50% 0.01%','99.99% 50%','66% 99.99%', '33% 99.99%', '0.01% 50%') {                
                gradient repeating-radial  @(
                    "ellipse 50% 50% at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 72            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialEllipseRepeatingRGBPentagon = @(
        {
            $alpha = "$([Math]::Round(100 / 5))%"
            $colors = 'red','green','blue'
            $degrees = 0
            @(foreach ($position in '50% 0.01%','99.99% 50%','66% 99.99%', '33% 99.99%', '0.01% 50%') {                
                gradient repeating-radial  @(
                    "ellipse 50% 50% at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 72            
            }) -join (',' + [Environment]::NewLine)
        }        
    )    
    radialEllipseRepeatingFullPentagon = @(
        {
            $alpha = "$([Math]::Round(100 / 5))%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            $degrees = 0
            @(foreach ($position in '50% 0.01%','99.99% 50%','66% 99.99%', '33% 99.99%', '0.01% 50%') {                
                gradient repeating-radial  @(
                    "ellipse 50% 50% at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 72            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialEllipseRepeatingRainbowCorners = @(
        {   
            $alpha = "$(100 / 4)%"
            @(foreach ($vertical in '0.01%') {
                foreach ($horizontal in '0.01%', '99.99%') {
                    gradient repeating-radial  @(
                        "ellipse 50% 50% at $Horizontal $vertical"
                        $colorNumber = 0
                        foreach ($color in 'red','brightYellow','yellow',
                            'green','blue','brightPurple', 'purple') {
                            $colorNumber++
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                        }
                    )
                }
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialEllipseRepeatingRainbowOverlapFourCorners = @(
        {   
            $alpha = "$(100 / 4)%"
            @(foreach ($vertical in '0.01%','99.99%') {
                foreach ($horizontal in '0.01%', '99.99%') {
                    gradient repeating-radial  @(
                        "ellipse 50% 50% at $Horizontal $vertical"
                        $colorNumber = 0
                        foreach ($color in 'red','brightYellow','yellow',
                            'green','blue','brightPurple', 'purple') {
                            $colorNumber++
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                        }
                    )
                }
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialEllipseRepeatingRainbowOverlap8 = @(
        {   
            $alpha = "$(100 / 8)%"
            @(foreach ($vertical in '25%','50%','75%') {
                foreach ($horizontal in '25%', '50%','75%') {
                    if ($horizontal -eq '50%' -and $vertical -eq '50%') {
                        continue
                    }
                    gradient repeating-radial  @(
                        "ellipse 50% 50% at $Horizontal $vertical"
                        $colorNumber = 0
                        foreach ($color in 'red','brightYellow','yellow',
                            'green','blue','brightPurple', 'purple') {
                            $colorNumber++
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                        }
                    )
                }
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialEllipseRepeatingRainbowVariableFourCorners = @(
        {   
            $alpha = "$(100 / 4)%"
            @(foreach ($vertical in '0.01%', '99.99%') {
                foreach ($horizontal in '0.01%', '99.99%') {
                    gradient repeating-radial  @(
                        "ellipse 50% 50% at $vertical $Horizontal"
                        $colorNumber = 0
                        foreach ($color in 'red','brightYellow','yellow',
                            'green','blue','brightPurple', 'purple') {
                            $colorNumber++
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                        }
                    )
                }
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialRepeatingRainbowVariableFourCorners = @(
        {
            $alpha = "$(100 / 4)%"
            @(foreach ($vertical in '0.01%', '99.99%') {
                foreach ($horizontal in '0.01%', '99.99%') {
                    gradient repeating-radial  @(
                        "circle closest-side at $horizontal $Vertical"
                        $colorNumber = 0
                        foreach ($color in 'red','brightYellow','yellow',
                            'green','blue','brightPurple', 'purple') {
                            $colorNumber++
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                        }
                    )
                }
            }) -join (',' + [Environment]::NewLine) 
        }
    )
    
    conicRepeating = { gradient repeating-conic '#4488ff 0% 5%',
        '#224488 5% 10%'
    }
    conicRepeatingVariable = { gradient repeating-conic 'var(--blue) 0% 5%',
        'var(--brightBlue) 5% 10%'
    }
    conicRepeatingColorMix = { 
        gradient repeating-conic 'color-mix(in srgb, var(--blue) 50%, transparent) 0% 5%',
            'color-mix(in srgb, var(--brightBlue) 50%, transparent) 5% 10%'
    }
    conicRepeatingRGB = {
        gradient repeating-conic @(
            'red 0% 5%',
            'green 5% 10%'   
            'blue 10% 15%'
        )
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
    conicRepeatingRGBOverlap = @(
        { gradient repeating-conic 'from 0deg at 25% 50%',
            'color-mix(in srgb, red 50%, transparent) 0% 5%',
            'color-mix(in srgb, green 50%, transparent) 5% 10%',
            'color-mix(in srgb, blue 50%, transparent) 10% 15%'
        }, { gradient repeating-conic 'from 180deg at 75% 50%',
            'color-mix(in srgb, red 50%, transparent) 0% 5%',
            'color-mix(in srgb, green 50%, transparent) 5% 10%',
            'color-mix(in srgb, blue 50%, transparent) 10% 15%'
        }
    )
    conicRepeatingRGBVariableOverlap = @(
        { gradient repeating-conic 'from 0deg at 25% 50%',
            'color-mix(in srgb, var(--red) 50%, transparent) 0% 5%',
            'color-mix(in srgb, var(--green) 50%, transparent) 5% 10%',
            'color-mix(in srgb, var(--blue) 50%, transparent) 10% 15%'
        }, { gradient repeating-conic 'from 180deg at 75% 50%',
            'color-mix(in srgb, var(--red) 50%, transparent) 0% 5%',
            'color-mix(in srgb, var(--green) 50%, transparent) 5% 10%',
            'color-mix(in srgb, var(--blue) 50%, transparent) 10% 15%'
        }
    )
    conicRepeatingRainbowOverlap = @(
        { gradient repeating-conic 'from 0deg at 25% 50%',
            'color-mix(in srgb, red 50%, transparent) 0% 2%',
            'color-mix(in srgb, orange 50%, transparent) 2% 4%',
            'color-mix(in srgb, yellow 50%, transparent) 4% 6%',
            'color-mix(in srgb, green 50%, transparent) 6% 8%',
            'color-mix(in srgb, blue 50%, transparent) 8% 10%',
            'color-mix(in srgb, indigo 50%, transparent) 10% 12%',
            'color-mix(in srgb, violet 50%, transparent) 12% 14%'
        }, { gradient repeating-conic 'from 180deg at 75% 50%',
            'color-mix(in srgb, red 50%, transparent) 0% 2%',
            'color-mix(in srgb, orange 50%, transparent) 2% 4%',
            'color-mix(in srgb, yellow 50%, transparent) 4% 6%',
            'color-mix(in srgb, green 50%, transparent) 6% 8%',
            'color-mix(in srgb, blue 50%, transparent) 8% 10%',
            'color-mix(in srgb, indigo 50%, transparent) 10% 12%',
            'color-mix(in srgb, violet 50%, transparent) 12% 14%'
        }
    )
    conicRepeatingRainbowVariableOverlap = @(
        { gradient repeating-conic 'from 0deg at 25% 50%',
            'color-mix(in srgb, var(--red) 50%, transparent) 0% 2%',
            'color-mix(in srgb, var(--brightYellow) 50%, transparent) 2% 4%',
            'color-mix(in srgb, var(--yellow) 50%, transparent) 4% 6%',
            'color-mix(in srgb, var(--green) 50%, transparent) 6% 8%',
            'color-mix(in srgb, var(--blue) 50%, transparent) 8% 10%',
            'color-mix(in srgb, var(--brightPurple) 50%, transparent) 10% 12%',
            'color-mix(in srgb, var(--purple), transparent) 12% 14%'
        }, { gradient repeating-conic 'from 180deg at 75% 50%',
            'color-mix(in srgb, var(--red) 50%, transparent) 0% 2%',
            'color-mix(in srgb, var(--brightYellow) 50%, transparent) 2% 4%',
            'color-mix(in srgb, var(--yellow) 50%, transparent) 4% 6%',
            'color-mix(in srgb, var(--green) 50%, transparent) 6% 8%',
            'color-mix(in srgb, var(--blue) 50%, transparent) 8% 10%',
            'color-mix(in srgb, var(--brightPurple) 50%, transparent) 10% 12%',
            'color-mix(in srgb, var(--purple), transparent) 12% 14%'
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
    
    conicRepeatingRainbowVariableCorners = @(
        { gradient repeating-conic 'from 0deg at 0% 0%',
            'color-mix(in srgb, var(--red) 50%, transparent) 0% 2%',
            'color-mix(in srgb, var(--brightYellow) 50%, transparent) 2% 4%',
            'color-mix(in srgb, var(--yellow) 50%, transparent) 4% 6%',
            'color-mix(in srgb, var(--green) 50%, transparent) 6% 8%',
            'color-mix(in srgb, var(--blue) 50%, transparent) 8% 10%',
            'color-mix(in srgb, var(--brightPurple) 50%, transparent) 10% 12%',
            'color-mix(in srgb, var(--purple), transparent) 12% 14%'
        }, { gradient repeating-conic 'from 180deg at 100% 0%',
            'color-mix(in srgb, var(--red) 50%, transparent) 0% 2%',
            'color-mix(in srgb, var(--brightYellow) 50%, transparent) 2% 4%',
            'color-mix(in srgb, var(--yellow) 50%, transparent) 4% 6%',
            'color-mix(in srgb, var(--green) 50%, transparent) 6% 8%',
            'color-mix(in srgb, var(--blue) 50%, transparent) 8% 10%',
            'color-mix(in srgb, var(--brightPurple) 50%, transparent) 10% 12%',
            'color-mix(in srgb, var(--purple), transparent) 12% 14%'
        }
    )
    
    conicRepeatingVariableFourCorners = @(
        {
            $alpha = "$(100 / 4)%"
            $colors = 'blue','brightBlue'
            $degrees = 0
            @(foreach ($vertical in '0%','100%') {
                foreach ($horizontal in '0%', '100%') {                    
                    gradient repeating-conic  @(
                        "from ${degrees}deg at $horizontal $Vertical"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                            
                            $from = "$([Math]::Round($colorNumber * 50/$colors.Count/2, 2))%"
                            $to =  "$([Math]::Round(++$colorNumber * 50/$colors.Count/2))%"
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                        }
                    )
                    $degrees += 90
                }
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    
    conicRGBVariableCorners = @(
        {
            $alpha = "$(100 / 2)%"
            $colors = 'red','green','blue'
            $degrees = 0
            @(foreach ($vertical in '0%') {
                foreach ($horizontal in '0%', '100%') {                    
                    gradient repeating-conic  @(
                        "from ${degrees}deg at $horizontal $Vertical"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                            
                            $from = "$([Math]::Round($colorNumber * 50/$colors.Count/2, 2))%"
                            $to =  "$([Math]::Round(++$colorNumber * 50/$colors.Count/2))%"
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                        }
                    )
                    $degrees += 180
                }
            }) -join (',' + [Environment]::NewLine)
        }                
    )
    
    conicRGBVariableOverlapHorizontal = @(
        {
            $alpha = "$(100 / 2)%"
            $colors = 'red','green','blue'
            $degrees = 0
            @(foreach ($vertical in '50%') {
                foreach ($horizontal in '25%', '75%') {                    
                    gradient repeating-conic  @(
                        "from ${degrees}deg at $horizontal $Vertical"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                            
                            $from = "$([Math]::Round($colorNumber * 50/$colors.Count/2, 2))%"
                            $to =  "$([Math]::Round(++$colorNumber * 50/$colors.Count/2))%"
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                        }
                    )
                    $degrees += 180
                }
            }) -join (',' + [Environment]::NewLine)
        }                
    )
    
    conicRGBVariableOverlapVertical = @(
        {
            $alpha = "$(100 / 2)%"
            $colors = 'red','green','blue'
            $degrees = 0
            @(foreach ($vertical in '25%', '75%') {
                foreach ($horizontal in '50%') {                    
                    gradient repeating-conic  @(
                        "from ${degrees}deg at $horizontal $Vertical"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                            
                            $from = "$([Math]::Round($colorNumber * 50/$colors.Count/2, 2))%"
                            $to =  "$([Math]::Round(++$colorNumber * 50/$colors.Count/2))%"
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                        }
                    )
                    $degrees += 180
                }
            }) -join (',' + [Environment]::NewLine)
        }                
    )
    
    conicRGBVariableFourCorners = @(
        {
            $alpha = "$(100 / 4)%"
            $colors = 'red','green','blue'
            $degrees = 0
            @(foreach ($vertical in '0%','100%') {
                foreach ($horizontal in '0%', '100%') {                    
                    gradient repeating-conic  @(
                        "from ${degrees}deg at $horizontal $Vertical"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                            
                            $from = "$([Math]::Round($colorNumber * 50/$colors.Count/2, 2))%"
                            $to =  "$([Math]::Round(++$colorNumber * 50/$colors.Count/2))%"
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                        }
                    )
                    $degrees += 90
                }
            }) -join (',' + [Environment]::NewLine)
        }
    )

    radialRainbowVariableFourCorners = @(
        {
            $alpha = "$(100 / 4)%"
            @(foreach ($vertical in '0.01%','99.99%') {
                foreach ($horizontal in '0.01%', '99.99%') {
                    gradient repeating-radial  @(
                        "circle closest-side at $horizontal $Vertical"
                        $colorNumber = 0
                        foreach ($color in 'red','brightYellow','yellow',
                            'green','blue','brightPurple', 'purple') {
                            $colorNumber++
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                        }
                    )
                }
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    conicRainbowVariableFourCorners = @(
        {
            $alpha = "$(100 / 4)%"
            $colors = 'red','brightYellow','yellow',
                'green','blue','brightPurple', 'purple'
            $degrees = 0
            @(foreach ($vertical in '0%','100%') {
                foreach ($horizontal in '0%', '100%') {                    
                    gradient repeating-conic  @(
                        "from ${degrees}deg at $horizontal $Vertical"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                            
                            $from = "$($colorNumber * 42/$colors.Count/2)%"                            
                            $to =  "$(++$colorNumber * 42/$colors.Count/2)%"
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                            # "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                        }
                    )
                    $degrees += 90
                }
            }) -join (',' + [Environment]::NewLine)
        }
        
    )
    radialEllipseRepeatingForegroundBackgroundTriangle = @(
        {
            $alpha = "$([Math]::Round(100 / 3))%"
            $colors = 'foreground','background'
            $degrees = 0
            @(foreach ($position in '0.01% 99.99%','50% 0.01%', '99.99% 99.99%') {
                gradient repeating-radial  @(
                    "ellipse 50% 50% at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 120           
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialEllipseRepeatingFullTriangle = @(
        {
            $alpha = "$([Math]::Round(100 / 3))%"
            # $colors = 'foreground','background'
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            $degrees = 0
            @(foreach ($position in '0.01% 99.99%','50% 0.01%', '99.99% 99.99%') {
                gradient repeating-radial  @(
                    "ellipse 50% 50% at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 120            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    radialEllipseRepeatingRGBTriangle = @(
        {
            $alpha = "$([Math]::Round(100 / 3))%"
            $colors = 'red','green','blue'
            $degrees = 0
            @(foreach ($position in '0.01% 99.99%','50% 0.01%', '99.99% 99.99%') {
                gradient repeating-radial  @(
                    "ellipse 50% 50% at $position"
                    $colorNumber = 0
                    foreach ($color in $colors) {
                        $colorNumber++
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $($colorNumber)rem"
                    }                    
                )
                $degrees += 72            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    conicRainbowVariableFullTriangle = @(
        {
            $alpha = "$([Math]::Round(100 / 3))%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            $degrees = 0
            @(foreach ($position in '0.01% 99.99%','50% 0.01%', '99.99% 99.99%') {    
                gradient repeating-conic  @(
                    "from ${degrees}deg at $position"
                    $colorNumber = 0                        
                    foreach ($color in $colors) {                            
                        $from = "$([Math]::Round($colorNumber * 50/$colors.Count/2, 2))%"
                        $to =  "$([Math]::Round(++$colorNumber * 50/$colors.Count/2))%"
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                    }
                )
                $degrees += 120
            
            }) -join (',' + [Environment]::NewLine)
        }
        
    )
    conicRainbowVariableFullHexagon = @(
        {
            $alpha = "$([Math]::Round(100 / 6))%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            $degrees = 0
            @(foreach ($position in '33% 0%','66% 0%', '100% 50%','66% 100%', '33% 100%', '0% 50%') {                
                gradient repeating-conic  @(
                    "from ${degrees}deg at $position"
                    $colorNumber = 0                        
                    foreach ($color in $colors) {                            
                        $from = "$([Math]::Round($colorNumber * 50/$colors.Count/2, 2))%"
                        $to =  "$([Math]::Round(++$colorNumber * 50/$colors.Count/2))%"
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                    }
                )
                $degrees += 60
            
            }) -join (',' + [Environment]::NewLine)
        }
        
    )
    conicRainbowVariableFullPentagon = @(
        {
            $alpha = "$([Math]::Round(100 / 5))%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            $degrees = 0
            @(foreach ($position in '50% 0%','100% 50%','66% 100%', '33% 100%', '0% 50%') {                
                gradient repeating-conic  @(
                    "from ${degrees}deg at $position"
                    $colorNumber = 0                        
                    foreach ($color in $colors) {                            
                        $from = "$([Math]::Round($colorNumber * 50/$colors.Count/2, 2))%"
                        $to =  "$([Math]::Round(++$colorNumber * 50/$colors.Count/2))%"
                        "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                    }
                )
                $degrees += 72            
            }) -join (',' + [Environment]::NewLine)
        }        
    )
    conicRainbowVariableFullFourCorners = @(
        {
            $alpha = "$(100 / 4)%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            $degrees = 0
            @(foreach ($vertical in '0%','100%') {
                foreach ($horizontal in '0%', '100%') {                    
                    gradient repeating-conic  @(
                        "from ${degrees}deg at $horizontal $Vertical"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                            
                            $from = "$([Math]::Round($colorNumber * 50/$colors.Count/2, 2))%"
                            $to =  "$([Math]::Round(++$colorNumber * 50/$colors.Count/2))%"
                            "color-mix(in srgb, var(--$color) $alpha, transparent) $from $to"
                        }
                    )
                    $degrees += 90
                }
            }) -join (',' + [Environment]::NewLine)
        }
        
    )
    linearHorizontalRainbowVariableFullFourCorners = @(
        {
            $alpha = "$(100 / 2)%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            @(
                foreach ($horizontal in 'left', 'right') {
                    gradient repeating-linear  @(
                        # "${degrees}deg"
                        "to $horizontal"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                                
                            $colorNumber++                        
                            "color-mix(in srgb, var(--$color) $alpha, transparent) ${colorNumber}rem"
                        }
                    )                
                }
            ) -join (',' + [Environment]::NewLine)
        }
        
    )
    linearVerticalRainbowVariableFullFourCorners = @(
        {
            $alpha = "$(100 / 2)%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            @(
                foreach ($vertical in 'top', 'bottom') {
                    gradient repeating-linear  @(
                        # "${degrees}deg"
                        "to $vertical"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                                
                            $colorNumber++                        
                            "color-mix(in srgb, var(--$color) $alpha, transparent) ${colorNumber}rem"
                        }
                    )                
                }
            ) -join (',' + [Environment]::NewLine)
        }
        
    )
    linearThatchRainbowVariableFull = @(
        {
            $alpha = "$(100 / 4)%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            @(
                foreach ($direction in 'right','bottom','left','top') {
                    gradient repeating-linear  @(
                        # "${degrees}deg"
                        "to $direction"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                                
                            $colorNumber++                        
                            "color-mix(in srgb, var(--$color) $alpha, transparent) ${colorNumber}rem"
                        }
                    )                
                }
            ) -join (',' + [Environment]::NewLine + (' ' * 2))
        }
        
    )
    linearRainbowVariableFullFourCorners = @(
        {
            $alpha = "$(100 / 4)%"
            $colors = 'foreground',
                'black', 'brightBlack',
                'red', 'brightRed',
                'green', 'brightGreen', 
                'yellow','brightYellow',
                'blue','brightBlue',
                'purple', 'brightPurple',
                'cyan', 'brightCyan',
                'white','brightWhite',
                'background'
            $degrees = 0
            @(foreach ($vertical in 'bottom','top') {
                foreach ($horizontal in 'left', 'right') {
                    gradient repeating-linear  @(
                        # "${degrees}deg"
                        "to $horizontal $Vertical"
                        $colorNumber = 0                        
                        foreach ($color in $colors) {                                
                            $colorNumber++                        
                            "color-mix(in srgb, var(--$color) $alpha, transparent) ${colorNumber}rem"
                        }
                    )
                    $degrees += 90
                }
            }) -join (',' + [Environment]::NewLine)
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

$gradientTypes = 'radial', 'linear','conic'

$blends = 'normal','darken','multiply','color-burn',
    'linear-dodge','screen','overlay','soft-light','hard-light',
    'difference','exclusion','hue', 'saturation', 'color', 'luminosity'

"<style>

@keyframes huerotate {
    0%, 100% { filter: hue-rotate(0deg)  }
    50% { filter: hue-rotate(360deg)  }
}

.huerotate {
    animation-name: huerotate;
    animation-iteration-count: infinite;    
    animation-duration: 5s;
}

.gradient-sample {     

    width:100%; height:100%;
    background-blend-mode: difference;    
}

.paused {
    animation-play-state: paused;
}
</style>"
foreach ($gradientType in $gradientTypes) {
    "<details open>"
    "<summary>$gradientType</summary>"
    foreach ($sampleId in @($SampleGradients.Keys -match $gradientType | Sort-Object)) {
        if ($SampleGradients[$sampleId] -as [ScriptBlock[]]) {
            "<div>"
                "<h3>$sampleId</h3>"
                                        
                "<details open>"
                    "<summary>PowerShell</summary>"
                    foreach ($gradient in $SampleGradients[$sampleId]) {
                        "<pre><code class='language-powershell'>"
                        [Web.HttpUtility]::HtmlEncode($gradient)
                        "</code></pre>"        
                    }
                "</details>"

                "<details open>"
                    "<summary>CSS</summary>"
                    "<pre><code class='language-css'>"
                    $css = "background-image:$(@(foreach ($gradient in $SampleGradients[$sampleId]) {
                        . $gradient
                    }) -join (', ' + [Environment]::NewLine))"
                    [Web.HttpUtility]::HtmlEncode($css)
                    "</code></pre>"
                "</details>"
                
                "<div class='gradient-preview'>"
                "<div id='$sampleId' class='gradient-sample' style='background-image:$(
                    @(foreach ($gradient in $SampleGradients[$sampleId]) {
                        . $gradient
                    }) -join ', '
                )'></div>"
                
            "</div>"
        }
    }
    "</details>"
}



"<style>.lowerSticky {    
    display: fixed;
    position: sticky;
    z-index: 50;
    bottom: 2.5%;
    max-width: 100%;
    text-align: center;
    mix-blend-mode: difference;
}</style>"

"<div class='lowerSticky'>"
if ($site.Includes.SelectPalette) {
    . $site.Includes.SelectPalette
}

if ($site.Includes.GetRandomPalette) {
    . $site.Includes.GetRandomPalette
}
"<script>"
@"
function toggleHueRotate() {
for (const element of [
    ...document.querySelectorAll('.gradient-sample')
]) {
    element.classList.toggle('huerotate')
}
}
"@
"</script>"
"<input id='toggleHueRotate' type='checkbox' onchange='toggleHueRotate()'></input>"
"<label for='toggleHueRotate'>Hue Rotate</label>"

"</div>"

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

