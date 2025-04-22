Set-Alias BuildFile ./buildFile.ps1
$lastBuildTime = [DateTime]::Now
Push-Location $PSScriptRoot
Get-ChildItem -Recurse -File | . buildFile

if (Test-Path .\LastBuildTime.txt) {
    $lastBuild = Get-Content -Path .\lastBuild.json -Raw | ConvertFrom-Json
    [Ordered]@{
        LastBuildTime = $lastBuildTime
        TimeSinceLastBuild = $lastBuildTime - $lastBuild
    } | ConvertTo-Json > .\lastBuild.json
} else {
    [Ordered]@{
        LastBuildTime = $lastBuildTime
    } | ConvertTo-Json > .\lastBuild.json
}


Pop-Location

