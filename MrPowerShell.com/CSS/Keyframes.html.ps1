param(
    [Alias('Keyframes')]
    [Collections.IDictionary]
    $Keyframe = [Ordered]@{
        'drop-in' = [Ordered]@{
            from = [Ordered]@{
                translate = "0 -150vh"
                scale = "1 200%"            
            }
            to = [Ordered]@{
                translate = "0 0" 
                scale = "1 100%"
            }
        }
        'drop-out' = [Ordered]@{
            from = [Ordered]@{
                translate = "0 0"
                scale = "1 100%"
            }
            to = [Ordered]@{
                translate = "0 150vh" 
                scale = "1 200%"
            }
        }
        'slide-in' = [Ordered]@{
            from = [Ordered]@{
                translate = "-150vw 0"
                scale = "200% 1"            
            }
            to = [Ordered]@{
                translate = "0 0" 
                scale = "100% 1"
            }
        }
        'slide-out' = [Ordered]@{
            from = [Ordered]@{
                translate = "0 0"
                scale = "100% 1"            
            }
            to = [Ordered]@{
                translate = "150vw 0" 
                scale = "200% 1"
            }
        }
        'invert' = [Ordered]@{
            from = [Ordered]@{
                filter = "invert(0%)"            
            }
            to = [Ordered]@{
                filter = "invert(100%)"            
            }
        }
        'blur-out' = [Ordered]@{
            from = [Ordered]@{
                filter = "blur(0px)"            
            }
            to = [Ordered]@{
                filter = "blur(5px)"            
            }
        }
        'blur-in' = [Ordered]@{
            from = [Ordered]@{
                filter = "blur(5px)"            
            }
            to = [Ordered]@{
                filter = "blur(0px)"            
            }
        }
        flip3d = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "rotateY(0) rotateX(0)"            
            }
            '50%' = [Ordered]@{
                transform = "rotateY(180deg) rotateX(180deg)"            
            }
        }
        rotate3d = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "rotateY(0) rotateX(0) rotateZ(0)"            
            }
            '25%' = [Ordered]@{
                transform = "rotateY(90deg) rotateX(90deg) rotateZ(90deg)"            
            }
            '50%' = [Ordered]@{
                transform = "rotateY(180deg) rotateX(180deg) rotateZ(180deg)"            
            }
            '75%' = [Ordered]@{
                transform = "rotateY(270deg) rotateX(270deg) rotateZ(270deg)"            
            }        
        }
        bounce = [Ordered]@{
            '0%, 20%, 50%, 80%, 100%' = [Ordered]@{
                transform = "translateY(0)"
            }
            '40%' = [Ordered]@{
                transform = "translateY(-30px)"
            }
            '60%' = [Ordered]@{
                transform = "translateY(-15px)"
            }
        }
        'fade-in' = [Ordered]@{
            from = [Ordered]@{
                opacity = "0"
                display = "none"
            }
            '1%' = [Ordered]@{display="block"}
            to = [Ordered]@{
                opacity = "1"
                display = "block"
            }
        }
        'fade-out' = [Ordered]@{
            from = [Ordered]@{
                opacity = "1"
                display = "block"
            }        
            to = [Ordered]@{
                opacity = "0"
                display = "none"
            }
        }    
        'rgb' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                color = "var(--red)"            
            }
            '33%' = [Ordered]@{
                color = "var(--green)"            
            }
            '66%' = [Ordered]@{
                color = "var(--blue)"            
            }
        }
        'foreground-to-background' = [Ordered]@{
            '0%' = [Ordered]@{
                color = "var(--foreground)"
            }
            '100%' = [Ordered]@{
                color = "var(--background)"            
            }
        }
        'background-to-foreground' = [Ordered]@{
            '0%' = [Ordered]@{
                color = "var(--background)"
            }
            '100%' = [Ordered]@{
                color = "var(--foreground)"            
            }
        }
        'terminal-rainbow' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                color = "var(--brightRed)"
            }
            '10%' = [Ordered]@{
                color = "var(--red)"
            }
            '20%' = [Ordered]@{
                color = "var(--brightYellow)"                
            }
            '30%' = [Ordered]@{
                color = "var(--yellow)"
            }
            '40%' = [Ordered]@{
                color = "var(--green)"
            }
            '50%' = [Ordered]@{
                color = "var(--brightGreen)"
            }
            '60%' = [Ordered]@{
                color = "var(--blue)"
            }
            '70%' = [Ordered]@{
                color = "var(--brightBlue)"
            }
            '80%' = [Ordered]@{
                color = "var(--purple)"
            }
            '90%' = [Ordered]@{
                color = "var(--brightPurple)"            
            }
        }
        'spin' = [Ordered]@{
            from = [Ordered]@{
                transform = "rotate(0deg)"            
            }
            to = [Ordered]@{
                transform = "rotate(360deg)"            
            }
        }
        'spin-reverse' = [Ordered]@{
            from = [Ordered]@{
                transform = "rotate(360deg)"            
            }
            to = [Ordered]@{
                transform = "rotate(0deg)"            
            }
        }
        'wiggle' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "rotate(-3deg)"            
            }
            '50%' = [Ordered]@{
                transform = "rotate(3deg)"            
            }
        }
        'wiggle-reverse' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "rotate(3deg)"            
            }
            '50%' = [Ordered]@{
                transform = "rotate(-3deg)"            
            }
        }
        'pulse' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "scale(1)"            
            }
            '50%' = [Ordered]@{
                transform = "scale(1.1)"            
            }
        }
        'pulse-reverse' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "scale(1.1)"            
            }
            '50%' = [Ordered]@{
                transform = "scale(1)"            
            }
        }
        'shake' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "translateX(0)"            
            }
            '25%' = [Ordered]@{
                transform = "translateX(-5px)"            
            }
            '75%' = [Ordered]@{
                transform = "translateX(5px)"            
            }
        }
        'shake-reverse' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "translateX(0)"            
            }
            '25%' = [Ordered]@{
                transform = "translateX(5px)"            
            }
            '75%' = [Ordered]@{
                transform = "translateX(-5px)"            
            }
        }    
        'skew' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "skewX(0)"            
            }
            '25%' = [Ordered]@{
                transform = "skewX(-10deg)"            
            }
            '75%' = [Ordered]@{
                transform = "skewX(10deg)"            
            }
        }    
        'skew3d' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "rotateX(0) rotateY(0)"            
            }
            '25%' = [Ordered]@{
                transform = "rotateX(10deg) rotateY(10deg)"            
            }
            '75%' = [Ordered]@{
                transform = "rotateX(-10deg) rotateY(-10deg)"            
            }
        }
        'skew-reverse' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "skewX(0)"            
            }
            '25%' = [Ordered]@{
                transform = "skewX(10deg)"            
            }
            '75%' = [Ordered]@{
                transform = "skewX(-10deg)"            
            }
        }
        'flip' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "rotateY(0)"            
            }
            '50%' = [Ordered]@{
                transform = "rotateY(180deg)"
            }
        }
        'flip-reverse' = [Ordered]@{
            '0%,100%' = [Ordered]@{
                transform = "rotateY(180deg)"
            }
            '50%' = [Ordered]@{
                transform = "rotateY(0)"
            }
        }
        'zoom-bounce' = [Ordered]@{
            '0%' = [Ordered]@{
                transform = "scale(1)"
            }
            '25%,75%' = [Ordered]@{
                transform = "scale(1.75)"
            }
            '50%' = [Ordered]@{
                transform = "scale(1.5)"
            }
            '100%' = [Ordered]@{
                transform = "scale(1)"
            }
        }
        'zoom-in' = [Ordered]@{
            from = [Ordered]@{
                transform = "scale(0.1)"
            }
            to = [Ordered]@{
                transform = "scale(1)"
            }
        }
        'zoom-out' = [Ordered]@{
            from = [Ordered]@{
                transform = "scale(1)"
            }
            to = [Ordered]@{
                transform = "scale(0.1)"
            }
        }
    }
)

function dictionaryToKeyframes {
    param(
        [Collections.IDictionary]$keyframe
    )
    process {
        foreach ($keyframeName in $keyframe.Keys) {
            $keyframeKeyframes = $keyframe[$keyframeName]
            "@keyframes $keyframeName {"
            foreach ($percent in $keyframeKeyframes.Keys) {
                "  $percent {"
                $props = $keyframeKeyframes[$percent]
                foreach ($prop in $props.Keys) {
                    $value = $props.$prop
                    "    ${prop}: $value;"
                }
                "  }"
            }
            "}"
            ".$keyframeName { animation-name: $keyframeName; }"
        }
    }    
}

"<style>"
dictionaryToKeyframes $Keyframe
foreach ($n in 1..10) {
    ".for$n { animation-duration: ${n}s; }"
}
".infinite { animation-iteration-count: infinite; }"
".forwards { animation-fill-mode: forwards; }"

".example {
    display: inline-block;
    text-align: center;
    font-size: 2em;
    padding: 1em;
    animation-duration: 2s;
}"

"</style>"

ConvertFrom-Markdown -InputObject (@'
## CSS Keyframes

<a href='#Examples'><button>Skip to Examples</button></a>

[CSS Keyframes](https://developer.mozilla.org/en-US/docs/Web/CSS/@keyframes) are a surprisingly simple way to write animations.

They take the form of:

~~~css
`@keyframes name { 
    keyframe { key: value; }
    keyframe2 { key: value; }
}
~~~

For example, to create a simple animation that moves an element from left to right, you could write:

~~~css
@keyframes left-to-right {
    from { left: 0; }
    to { left: 100%; }
}
~~~

Keyframes can also specify multiple steps in the animation, using percentages:

~~~css
@keyframes bounce {
    0%, 20%, 50%, 80%, 100% {
        transform: translateY(0);
    }
    40% {
        transform: translateY(-30px);
    }
    60% {
        transform: translateY(-15px);
    }
}
~~~


Keyframes are quite cool, and _most_ of this page is a demonstration of the keyframes defined in the `$keyframe` variable above.

Before we get to that, let's talk about how we can generate the keyframes in PowerShell.
'@ + @"

Eagle eyed readers will notice that keyframes, like all of CSS, are basically hashtables.

Making things even easier, keyframes are limited in depth, so we don't even have to use recursion.

Here's a simple function that will convert a dictionary to keyframes:

~~~PowerShell
function dictionaryToKeyframes {
$(Get-Command dictionaryToKeyframes | Select-Object -ExpandProperty Definition)
}
~~~

So we can just define a keyframe in a dictionary, and then call the function to generate the keyframes.

( or include it inline )

Then, our keyframes can be defined like this:
~~~PowerShell
`$keyframes = [Ordered]@{
    '0%, 20%, 50%, 80%, 100%' = [Ordered]@{
        transform = 'translateY(0)'
    }
    '40%' = [Ordered]@{
        transform = 'translateY(-30px)'
    }
    '60%' = [Ordered]@{
        transform = 'translateY(-15px)'
    }
}
~~~

For even better bonus points, we can remember how parameters work in this site generator:

If a site or a page defintes `$keyframe` variable that maps to the parameter, then it will be passed to this script and display a different set of keyframes.
"@) | 
    Select -ExpandProperty Html


"<details>"
"<summary>"
"View Source"
"</summary>"
"<pre><code class='language-powershell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"
"</details>"
'<div>'
"<h2 id='Examples'>Examples</h2>"
@(
foreach ($key in $keyframe.Keys) {
    "<p class='$key example infinite for5'>$key</p>"
}
) -join '</div>
<div>'
'</div>'