<#
.SYNOPSIS
    Digital Clock
.DESCRIPTION
    A Segmented Digital Clock in HTML and JavaScript
.NOTES
    ### Got the time?

    Your browser certainly does.

    This is a simple digital clock built in PowerShell and running in your browser.    
#>
param(
[switch]
$ShowTimeSeconds = $true,

[switch]
$ShowTimeHundrenthsSeconds
)


$css = @"

.grid { height: 100%; display: grid; place-items: center; width: 20ch; margin: auto; font-size: 2.0rem; text-align: center; }

.digital-clock { width: 20ch; font-size: 2.0rem; text-align: center; }

"@


"<div class='grid'>"
"<div class='digital-clock'></div>"
"</div>"
"<style>$css</style>"
"<script>"
@'
const digits = ["🯰","🯱","🯲","🯳","🯴","🯵","🯶","🯷","🯸","🯹"]
const timeFormat = new Intl.DateTimeFormat(undefined, { hour: "numeric" });
const timeFormatOptions = timeFormat.resolvedOptions();

function getClockDigits(n) {
    if (! (typeof(n) === typeof(1))) { return }
    if (n > 100) { return }
    const arr = []
    if (n >= 10) {
        const n10 = Math.floor(n / 10)
        const n1 = n % 10
        arr.push(digits[n10])
        arr.push(digits[n1])
    } else {
        arr.push(digits[0])
        arr.push(digits[n])                
    }
    return arr;
}
'@

@"
function tick() {
    const now = new Date()
    const segments = []

    let hours = now.getHours()
    if (timeFormatOptions.hour12) {
        hours = hours % 12
    }

    for (const segment of [...getClockDigits(hours)]) {
        segments.push(segment)    
    }
    
    segments.push(":")

    for (const segment of [...getClockDigits(now.getMinutes())]) {
        segments.push(segment)    
    }
        
    $(
        if (-not $HideTimeSeconds) {
            '
    segments.push(":")

    for (const segment of [...getClockDigits(now.getSeconds())]) {
        segments.push(segment)    
    }                
            '
        } 
    )
    

    $(
        if ((-not $HideTimeSeconds) -and $ShowTimeHundrenthsSeconds) {
            '
    const hundredthSecond = Math.floor(now.getMilliseconds() / 10)

    segments.push(".")

    for (const segment of [...getClockDigits(hundredthSecond)]) {
        segments.push(segment)    
    }                
            '
        } 
    )                

    if (timeFormatOptions.hour12) {
        if (now.getHours() < 12) {
            segments.push("AM")
        } else {
            segments.push("PM") 
        }
    }

    for (const element of [
        ...document.getElementsByClassName("digital-clock")
    ]) {
        element.innerText = segments.join("")    
    }    
}
setInterval(tick, 73)
"@


"</script>"

