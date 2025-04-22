#requires -Module PSSVG

SVG -Content @(
    SVG.Palette -PaletteName Andromeda
    SVG.defs -Content @(        
        SVG.pattern -id 'simplePattern' -patternUnits 'userSpaceOnUse' -width '128' -height '128' -TransformOrigin '50% 50%' -Content @(

        
            SVG.path -D @(
                "M 56, 0"
                
                $pixelRange    = 0..128
                $angleStart    = 180
                $angleIncrease = 360 / $pixelRange.Length
        
                foreach ($t in $pixelRange) {         
        
                    "$((64 + ([Math]::Cos((($angleStart + ($t*$angleIncrease)) * [Math]::PI)/180) * 8)), $t)"
                }
                "M 72, 0"
                foreach ($t in $pixelRange) {
                    "$((64 + ([Math]::Cos((($angleStart + ($t*$angleIncrease)) * [Math]::PI)/180) * -8)), $t)"
                }        
            ) -Stroke "#199ac1" -Fill 'transparent'

            SVG.path -D @(
                "M 0, 56"
                
                $pixelRange    = 0..128
                $angleStart    = 180
                $angleIncrease = 360 / $pixelRange.Length
        
                foreach ($t in $pixelRange) {         
        
                    "$($t,(64 + ([Math]::Cos((($angleStart + ($t*$angleIncrease)) * [Math]::PI)/180) * 8)))"
                }
                "M 0, 72"
                foreach ($t in $pixelRange) {
                    "$($t,(64 + ([Math]::Cos((($angleStart + ($t*$angleIncrease)) * [Math]::PI)/180) * -8)))"
                }        
            ) -Stroke "#199ac1" -Fill 'transparent'

            # SVG.animateTransform -Type 'scale' -Values "1;3;1" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName patternTransform -Additive 'sum'
            # SVG.animateTransform -Type 'translate' -Values "0 0;0 2048;0 0" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName patternTransform -Additive 'sum'
            # SVG.animateTransform -Type 'rotate' -Values "0;360;0" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName patternTransform -Additive 'sum'
            # SVG.line -X1 0 -Y1 (Get-Random -Max 128) -X2 128 -Y2 (Get-Random -Max 128) -Stroke '#4488ff' -StrokeWidth 1 -Class 'foreground-stroke'
            # SVG.line -Y1 0 -X1 (Get-Random -Max 128) -Y2 128 -X2 (Get-Random -Max 128) -Stroke '#4488ff' -StrokeWidth 1 -Class 'foreground-stroke'
            # SVG.line -X1 0 -Y1 (Get-Random -Max 128) -X2 128 -Y2 (Get-Random -Max 128) -Stroke '#4488ff' -StrokeWidth 1 -Class 'foreground-stroke'
            # SVG.line -Y1 0 -X1 (Get-Random -Max 128) -Y2 128 -X2 (Get-Random -Max 128) -Stroke '#4488ff' -StrokeWidth 1 -Class 'foreground-stroke'
            # SVG.line -X1 32 -X2 32 -Y1 0 -Y2 64 -Stroke '#4488ff' -StrokeWidth 1 -Class 'foreground-stroke'
            # SVG.circle -Cx 32 -Cy 32 -R 32 -Fill '#4488ff' -Class 'foreground-fill'
            # SVG.ConvexPolygon -SideCount 6 -CenterX 64 -CenterY 64 -Radius 72 -Class 'foreground-stroke' -Stroke '#4488ff' -StrokeWidth 0.1% -Fill 'transparent'
            # SVG.ConvexPolygon -SideCount 4 -CenterX 64 -CenterY 64 -Radius 64 -Class 'foreground-stroke' -Stroke '#4488ff' -StrokeWidth 0.1% -Fill 'transparent'
            # SVG.ConvexPolygon -SideCount 4 -CenterX 64 -CenterY 64 -Radius 42 -Class 'foreground-stroke' -Stroke '#4488ff' -Rotate 45 -StrokeWidth 0.1% -Fill 'transparent'
            # SVG.Arbelos -Radius 32 -CenterX 64 -CenterY 64 -Midpoint .1 -Class 'foreground-stroke' -Stroke '#4488ff' -StrokeWidth 0.1% -Fill 'transparent'           
            # SVG.Arbelos -Radius 32 -CenterX 32 -CenterY 64 -Midpoint .1 -Class 'foreground-stroke' -Stroke '#4488ff' -StrokeWidth 0.1% -Fill 'transparent'
            #SVG.Rose -Frequency 2 -CenterX 64 -CenterY 64 -Radius 42 -Class 'foreground-stroke' -Stroke '#4488ff' -StrokeWidth 0.1% -Fill 'transparent' -TransformOrigin '64 64' -Content @(
                # SVG.animateTransform -Type 'rotate' -Values "0;360;0" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName transform -Additive 'sum'
            # )
            # SVG.ConvexPolygon -SideCount 6 -CenterY 96 -CenterX 32 -Radius 32 -Class 'foreground-stroke' -Stroke '#4488ff' -StrokeWidth 0.1% -Fill 'transparent'
            # SVG.ConvexPolygon -SideCount 3 -CenterX 96 -CenterY 96 -Radius 32 -Class 'foreground-stroke' -Stroke '#4488ff' -StrokeWidth 0.1% -Fill 'transparent'
            #SVG.line -Y1 32 -Y2 32 -X1 0 -X2 64 -Stroke '#4488ff' -StrokeWidth 1 -Class 'foreground-stroke'         
        )
    )
    $hugeSize = 3000
    SVG.rect -width "$hugeSize%" -height "$hugeSize%" -Y "-$($hugeSize / 2)%" -Fill 'transparent' -Class 'background-fill'
    SVG.rect -width "$hugeSize%" -height "$hugeSize%" -Y "-$($hugeSize / 2)%"-fill 'url(#simplePattern)'
    SVG.rect -width "$hugeSize%" -height "$hugeSize%" -Y "-$($hugeSize / 2)%"-fill 'url(#simplePattern)'  -TransformOrigin '50% 50%' -Content @(
        SVG.animateTransform -Type 'translate' -Values "0 0;64 0;0 0" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName transform -Additive 'sum'
        SVG.animateTransform -Type 'scale' -Values "1;1.1;1" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName transform -Additive 'sum'
        # SVG.animateTransform -Type 'rotate' -Values "0;361;0" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName transform -Additive 'sum'
    )
    SVG.rect -width "$hugeSize%" -height "$hugeSize%" -Y "-$($hugeSize / 2)%" -fill 'url(#simplePattern)' -TransformOrigin '50% 50%' -Content @(
        SVG.animateTransform -Type 'translate' -Values "0 0;-64 0;0 0" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName transform -Additive 'sum'
        SVG.animateTransform -Type 'scale' -Values "1;.9;1" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName transform -Additive 'sum'
        # SVG.animateTransform -Type 'translate' -Values "0 0;50 0;0 0" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName transform -Additive 'sum'
        # SVG.animateTransform -Type 'rotate' -Values "0;359;0" -RepeatCount 'indefinite' -Dur "8.4s"  -AttributeName transform -Additive 'sum'
    )
) | Select-Object -ExpandProperty OuterXml