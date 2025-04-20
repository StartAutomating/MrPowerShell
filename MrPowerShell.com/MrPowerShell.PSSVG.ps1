#requires -Modules PSSVG
$fontSettings = [Ordered]@{
    TextAnchor        = 'middle'
    AlignmentBaseline = 'middle'
    Style             = "font-family: 'Roboto';"
    Class             = 'foreground-fill'
    Fill              = '#4488ff'        
}


foreach ($variant in '', 'Animated') {
    svg -ViewBox 400,400 @(
        svg.defs @(
            SVG.GoogleFont -FontName Abel
        )
    
    
        svg.symbol -Id psChevron -Content @(
            svg.polygon -Points (@(
                "40,20"
                "45,20"
                "60,50"
                "35,80"
                "32.5,80"
                "55,50"
            ) -join ' ')
        ) -ViewBox 100, 100    
        
        $rx = "15%"
        $ry = "25%"

        svg.ellipse -StrokeWidth 1.25 -Fill transparent -Cx 50% -Cy 50% -Stroke '#4488ff' -Ry $ry -Rx $rx -Class foreground-stroke -Children @(
            if ($variant -match 'Animated') {
                svg.animate -AttributeName 'rx' -Values "$rx; 21%; $rx" -Dur '4.2s' -RepeatCount 'indefinite'
            }
        )
                        
        svg.use -Href '#psChevron' -Fill '#4488ff' -TransformOrigin '50% 50%' -Width 20% -X 40% -Y 0% -Class foreground-fill # -Transform 'rotate(90 200 200) translate(15 -50) scale(1 1.25)' 
        
    )  -OutputPath (Join-Path $PSScriptRoot "MrPowerShell$(if ($variant) {"-$Variant"}).svg")
    
}

