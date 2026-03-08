if ($psScriptRoot) { Push-Location $psScriptRoot }

[PSCustomObject]@{
    PSTypeName = 'com.mrpowershell.logo'
    name = 'MrPowerShell'
    svg = Get-Content -Raw ../../MrPowerShell.svg
}

[PSCustomObject]@{
    PSTypeName = 'com.mrpowershell.logo'
    name = 'MrPowerShell-Animated'
    svg = Get-Content -Raw ../../MrPowerShell-Animated.svg
}

if ($psScriptRoot) { Pop-Location }