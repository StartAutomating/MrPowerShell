if ($psScriptRoot) { Push-Location $psScriptRoot }
Get-Content -Raw ../../MrPowerShell.svg
if ($psScriptRoot) { Pop-Location }