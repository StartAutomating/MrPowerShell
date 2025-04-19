param([string]$FilePattern = '\.(?>css|csv|html?|js|json|svg|rss|xml)\.ps1$')

$filesToMake = 
    @(Get-ChildItem -Recurse -Filter "*.*.ps1" |
    Where-Object Name -Match $filePattern)

$scriptsToMake = 
    foreach ($file in $filesToMake) {
        $executionContext.InvokeCommand.GetCommand($file.FullName,'ExternalScript')
    }

$PaletteName = 'Konsolas'

function layout {
$argsAndinput = @($args) + @($input)
@"
<html>
    <head>
        <title>$Title</title>
        <meta name='viewport' content='width=device-width, initial-scale=1' />
        <link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/$PaletteName.css'>
        $OpenGraph
        $ImportMap
    </head>
    <body>
$($argsAndinput -join [Environment]::NewLine)
    </body>
<html>
"@
}


$buildTimerStart = [DateTime]::Now
foreach ($scriptToMake in $scriptsToMake) {
    $scriptRoot = $scriptToMake.Source | Split-Path
    Push-Location $scriptRoot
    $fileOutputPath = $scriptToMake.Source -replace '\.ps1'
    $title = ($scriptToMake.Source | Split-Path -Leaf) -replace $filePattern
    if ($file.Directory.Name -eq 
        $title
    ) {
        $indexInstead = $file.Name -replace ([Regex]::Escape($title)), 'index' -replace '\.ps1$'
        $fileOutputPath = $indexInstead
    }
    $fileOutput = . $scriptToMake
    if ($fileOutput -is [IO.FileInfo] -or 
        $fileOutput -is [Collections.IList] -and $fileOutput -as [IO.FileInfo[]]
    ) {
        $fileOutput
    } 
    elseif ($fileOutput -is [xml]) {
        $fileOutput.Save($fileOutputPath)
        if ($?) {
            Get-Item -Path $fileOutputPath
        }
    }
    else {
        if ($fileOutputPath -match '\.html$' -and -not ($fileOutput -match '<html>')) {
            # Frame the HTML
            $fileOutput | layout > $fileOutputPath
        } else {
            $fileOutput > $fileOutputPath
        }
        
        if ($?) {
            Get-Item -Path $fileOutputPath
        }
    }
    
    Pop-Location
}

$buildTimerEnd = [DateTime]::Now
$buildTimeSpan = $buildTimerEnd - $buildTimerStart

Write-Host "Built $($filesToMake.Length) files in $buildTimeSpan" -ForegroundColor Cyan