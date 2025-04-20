Get-ChildItem -Path ($PSScriptRoot | Split-Path) -Recurse -File | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object Name, LastWriteTime |
    ConvertTo-Html -Fragment

