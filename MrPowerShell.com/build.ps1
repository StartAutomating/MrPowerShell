Set-Alias BuildFile ./buildFile.ps1

Push-Location $PSScriptRoot
Get-ChildItem -Recurse -File | . buildFile
Pop-Location

