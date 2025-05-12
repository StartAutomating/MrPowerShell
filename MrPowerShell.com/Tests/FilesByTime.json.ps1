Get-ChildItem -Path ($PSScriptRoot | Split-Path) -Recurse | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object FullName, CreationTime, LastWriteTime, Length
