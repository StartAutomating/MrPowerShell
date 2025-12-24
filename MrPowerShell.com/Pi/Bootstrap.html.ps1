<#
.SYNOPSIS
    Raspberry Pi Bootstrap
.DESCRIPTION
    Bootstrap installs on Raspberry Pi.
.NOTES
    PowerShell is pretty awesome on the Raspberry Pi.

    Here's a script to get PowerShell installed on the Pi.
.LINK
    https://MrPowerShell.com/Pi/Bootstrap
.LINK
    https://MrPowerShell.com/Pi/poshpi.sh
#>
param(
[uri]
$InstallPowerShellOnPi = 
    'https://learn.microsoft.com/en-us/powershell/scripting/install/community-support#raspberry-pi-os'
)


Push-Location $PSScriptRoot


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

"<article>"
$markdown | ConvertFrom-Markdown | Select-Object -ExpandProperty Html
"</article>"
#endregion

$installScript = ''

$installationInstructionsHtml = Invoke-RestMethod $InstallPowerShellOnPi -ErrorAction Ignore
$codePattern = [Regex]::new('<code.+?</code>', 'IgnoreCase,Singleline')
if ($InstallPowerShellOnPi) {
    foreach ($match in $codePattern.Matches($installationInstructionsHtml)) {
        if ($match -notmatch 'linux-arm' -or $match -notmatch '# Start PowerShell') {
            continue 
        }
        $installScript = $match -replace '<[^>]+>' -replace '# Start PowerShell', '
chmod +x ~/powershell/pwsh
# Start PowerShell
' -replace '^', '#! /bin/sh
'

        $installScript > ./poshpi.sh        
    }
} else {
    # If we are here, then learn.microsoft.com is down or the content has moved.
    # Luckily, we can just keep carrying on a previous script after one has been uploaded.
    $installScript = Invoke-RestMethod -Uri "https://MrPowerShell.com/Pi/poshpi.sh" -errorAction Ignore
    if ($installScript) {
        $installScript > ./poshpi.sh
        chmod +x ./poshpi.sh
    }
}


if ($installScript) {

"<pre><code language='lang-sh'>
$([Web.HttpUtility]::HtmlEncode($installScript))
</code></pre>"
}

if ($site.Includes.CopyCode) {
    . $site.Includes.CopyCode 
}

Pop-Location