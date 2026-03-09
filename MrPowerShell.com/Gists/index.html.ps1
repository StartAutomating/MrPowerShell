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

if ($PSScriptRoot) { Push-Location $psScriptRoot }

if (-not $script:myGists) {            
    $script:myGists = . ../xprc/com.github.api.users.gists/index.json.ps1
}

$script:myGists | 
    ConvertTo-Json -Depth 10 > MyGists.json

"<ul>"
$script:myGists | 
    Sort-Object updated_at -Descending |
    ForEach-Object {
        "<li>"
            "<a href='$($_.html_url)' target='_blank' class='gist'>$([Web.HttpUtility]::HtmlEncode($_.description))</a>"
        "</li>"
    }
"</ul>"

if ($PSScriptRoot) { Pop-Location }