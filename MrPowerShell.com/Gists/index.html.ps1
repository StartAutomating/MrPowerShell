<#
.SYNOPSIS
    My Gists
.DESCRIPTION
    My GitHub Gists.
.EXAMPLE
    ./index.html.ps1
.LINK
    https://MrPowerShell.com/Gists/
#>
param(
    [string]$GitHubUser = 'StartAutomating'
)
$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File
$title = $myHelp.SYNOPSIS
$description = $myHelp.description.text -join [Environment]::NewLine

if (-not $script:myGists) {
    $script:myGists = Invoke-RestMethod -Uri "https://api.github.com/users/$GitHubUser/gists"    
}

$script:myGists | ConvertTo-Json -Depth 10 > MyGists.json

"<ul>"
$script:myGists | 
    Sort-Object updated_at -Descending |
    ForEach-Object {
        "<li>"
            "<a href='$($_.html_url)' target='_blank' class='gist'>$([Web.HttpUtility]::HtmlEncode($_.description))</a>"
        "</li>"
    }
"</ul>"