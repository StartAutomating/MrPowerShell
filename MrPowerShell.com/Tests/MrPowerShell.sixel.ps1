#requires -Module Sixel
param(
    [string]
    $Image = 'https://MrPowerShell.com/MrPowerShell.png'
)

ConvertTo-Sixel -Url $Image -Force