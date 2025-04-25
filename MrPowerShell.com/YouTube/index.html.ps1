#requires -Module oEmbed
Push-Location $PSScriptRoot
@"
<style>
.grid-container {
    display: grid;
    grid-template-columns: 1fr 2fr 1fr;    
}
.grid-center {
    text-align: center;
    grid-column: 2;
    padding: 2em;
}
</style>
"@
"<div class='grid-container'>"
./index.json.ps1 |
    Sort-Object @{
        Expression = "Year"
        Descending=$true
    }, @{
        Expression="Name"
        Descending = $false
    } |   
    ForEach-Object { 
        Get-OEmbed -Url $_.YouTubeUrl -MaxHeight 1280 -MaxWidth 720
    } | 
    ForEach-Object {
        "<div class='grid-center'>"
        $_.html
        "</div>"
    }
"</div>"
Pop-Location