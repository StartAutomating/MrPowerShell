<#
.SYNOPSIS
    Raspberry Pi and PowerShell
.DESCRIPTION
    Using PowerShell on a Raspberry Pi
.EXAMPLE

.LINK
    https://MrPowerShell.com/Pi/
.NOTES
    Like many nerds I know, I play with Raspberry Pis.

    Of course, I play with them using PowerShell.

    ### Installing PowerShell on Raspberry Pi

    Microsoft provides pretty decent instructions for
    [Installing PowerShell on Pi](https://learn.microsoft.com/en-us/powershell/scripting/install/community-support#raspberry-pi-os).

    They do miss one key step: you need to use `chmod +x` to set pwsh to execute to get up and running.

    ### What Can We Do?

    Once PowerShell is installed, _almost_ everything works normally.
    
    Since PowerShell core is cross-platform, there's a good chance your script will work without changes.

    If it's PowerShell, and it runs on Linux, it will probably run on Pi.

    If the script depends on a binary, it may not work.  If it depended on features of Windows, like WMI, it will not work.

    But almost everything is fair game.
#>

$myHelp = Get-Help $myInvocation.MyCommand.ScriptBlock.File

if ($Page -isnot [Collections.IDictionary]) {
    $Page = [Ordered]@{}
}
$page.Title = $myHelp.SYNOPSIS
$page.Description = $myHelp.description.text -join [Environment]::NewLine
$myNotes = $myHelp.alertset.alert.text -join [Environment]::NewLine
if ($myNotes) {
    ConvertFrom-Markdown -InputObject $myNotes | Select -expand HTML
}