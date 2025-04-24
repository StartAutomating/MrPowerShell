#requires -Module PSDevOps
Import-BuildStep -SourcePath (
    Join-Path $PSScriptRoot 'GitHub'
) -BuildSystem GitHubWorkflow

Push-Location ($PSScriptRoot | Split-Path)
New-GitHubWorkflow -Name "MrPowerShellSync" -On Every15Minutes,
    Demand -Job SyncMrPowerShell -OutputPath .\.github\workflows\SyncMrPowerShell.yml

Pop-Location