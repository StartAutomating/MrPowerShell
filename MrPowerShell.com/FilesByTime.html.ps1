Get-ChildItem -Path ($PSScriptRoot | Split-Path) -Recurse -File | 
    Sort-Object CreationTime -Descending | 
    Select-Object Name, CreationTime |
    ConvertTo-Html -Fragment

