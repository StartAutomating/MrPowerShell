<#
.SYNOPSIS
    Shows the Environment variables
.DESCRIPTION
    Shows the environment variables, except for any that look like secrets.

    Use with caution

    This attempts to omit any variables that look like they might be secrets.  

    Additional secret names can be defined in the $site
#>
param(
[Alias('ShowEnvironmentVariable','ShowEnvironmentVariables')]
[switch]
$DebugEnvironment,
[string[]]
$SecretName,
[string]$SecretPattern = '(password|secret|key|token|passphrase|credential|auth)'
)

if (-not $DebugEnvironment) {
    Write-Warning "Environment variables are not shared for this site.  Skipping."
    return
}

$Title = "Environment Variables"
$Description = "Environment variables for this site.  This is a list of all environment variables that are not considered secrets."

"<table class='buildVariables'>"
foreach ($environmentVariable in (Get-ChildItem -Path env:)) {    
    "<tr>"
    "<td class='variableName'>"
    [Web.HttpUtility]::HtmlEncode($environmentVariable.Name)
    "</td>"
    "<td class='variableValue'>"
    if ($environmentVariable.Name -match $SecretPattern) {
        continue
        # [Web.HttpUtility]::HtmlEncode('*' * (Get-Random -Minimum ($environmentVariable.Value.Length * 2) -Maximum ($environmentVariable.Value.Length * 3)))
    } 
    elseif ($secretName -and $environmentVariable.Name -in $secretName) {
        continue
    } else {
        [Web.HttpUtility]::HtmlEncode($environmentVariable.Value)    
        continue
    }
    
    "</td>"
    "</tr>"
}
"</table>"