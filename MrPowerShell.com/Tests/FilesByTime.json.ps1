Get-ChildItem -Path ($PSScriptRoot | Split-Path) -Recurse | 
    Sort-Object CreationTime -Descending | 
    Select-Object FullName, CreationTime, LastWriteTime, Length
