<#
.SYNOPSIS
    My YouTube
.DESCRIPTION
    My YouTube Videos
.NOTES
    I occassionally record videos or speak at conferences that record the sessions.

    I've gathered them all here for your viewing pleasure.

    Please, enjoy!
.LINK
    https://MrPowerShell.com/YouTube
#>

param()
#requires -Module oEmbed
$myHelp = Get-Help $myInvocation.MyCommand.ScriptBlock.File
if ($page -isnot [Collections.IDictionary]) {
    $page = [Ordered]@{}
}
$title = $page['title'] = $myHelp.Synopsis
$description = $page['description'] = $myHelp.Description.text -join [Environment]::NewLine
$myNotes = $myHelp.alertSet.alert.text -join [Environment]::NewLine
if ($myNotes) {
    ConvertFrom-Markdown -InputObject $myNotes |
        Select-Object -ExpandProperty HTML
}

Push-Location $PSScriptRoot
@"
<style>
.youtube-video-grid { 
    display: grid; 
    grid-template-columns: repeat(auto-fit, minmax(360px, 1fr));
    gap: 2.5em; 
    margin: 2.5em
}
.youtube-video-grid h3 {
    text-align: center;
}
</style>
"@
"<div class='youtube-video-grid'>"
./index.json.ps1 |
    Sort-Object @{
        Expression = "Year"
        Descending=$true
    }, @{
        Expression="Name"
        Descending = $false
    } |   
    ForEach-Object { 
        Get-OEmbed -Url $_.YouTubeUrl -MaxHeight 480 -MaxWidth 360
    } | 
    ForEach-Object {
        "<div>"        
        "<div>$($_.html)</div>"
        "<h3>$($_.title)</h3>"
        "</div>"
    }
"</div>"
Pop-Location
