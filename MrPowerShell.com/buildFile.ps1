param(
[Parameter(ValueFromPipeline)]
[IO.FileInfo]
$File
)

Set-Alias layout "$pwd/layout.ps1"

$start = [datetime]::Now

:nextFile foreach ($file in $input) {
    $outFile = $file.FullName -replace '\.ps1$'
    $Output = switch ($file.Extension) {
        '.md' {
            $title = $file.Name
            $outFile = $file.FullName -replace '\.md$', '.html'
            (ConvertFrom-Markdown -Path $file.FullName).Html |
                layout
        }
        '.ps1' {
            if ($file.Name -notmatch '\..+?\.ps1$') {
                continue nextFile
            }
            . $file
        }
    }

    if ($null -eq $Output) {
        continue nextFile
    }
                
    if ($output -is [xml]) {
        $output.Save($outFile)
        if ($?) {
            Get-Item -Path $outFile
        }
    } elseif ($outputFiles = foreach ($out in $Output) {
        if ($out -is [IO.FileInfo]) {
            $out
        }
    }) {
        $outputFiles
    } else {
        if ($outFile -match '\.html$' -and -not ($output -match '<html>')) {
            $output | layout > $outFile
        } else {
            $output > $outFile
        }
        if ($?) {
            Get-Item -Path $outFile
        }
    }
}

$end = [datetime]::Now
