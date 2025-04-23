param(
[Parameter(ValueFromPipeline)]
[IO.FileInfo]
$File
)

$permalink = 'pretty'
$start = [datetime]::Now
$layoutAtPath = [Ordered]@{}

:nextFile foreach ($file in $input) {
    $outFile = $file.FullName -replace '\.ps1$'
    $fileRoot = $file.FullName | Split-Path
    
    if (-not $layoutAtPath[$fileRoot]) {
        while ($fileRoot) {
            $layoutPath = Join-Path $fileRoot 'layout.ps1'
            if (Test-Path $layoutPath) {
                $layoutAtPath[$fileRoot] = $layoutPath
                break
            }
            $fileRoot = $fileRoot | Split-Path
        }
    }

    if ($layoutAtPath[$fileRoot]) {
        Set-Alias layout $layoutAtPath[$fileRoot]
    }
    
    $Output = switch ($file.Extension) {
        '.md' {
            $title = $file.Name -replace '\.md$' -replace 'index'
            $outFile = $file.FullName -replace '\.md$', '.html'
            (ConvertFrom-Markdown -Path $file.FullName).Html |
                layout
        }
        '.ts' {
            $outFile = $file.FullName -replace '\.ts$', '.js'
            tsc $file.FullName -module es6 -target es6
        }
        '.ps1' {
            # Skip all files that are not *.someExtension.ps1
            if ($file.Name -notlike '*.*.ps1') {
                continue nextFile
            }
            $scriptCmd = Get-Command -Name $file.FullName
            foreach ($requirement in $scriptCmd.ScriptBlock.Ast.ScriptRequirements.RequiredModules) {
                $alreadyLoaded = Import-Module -Name $requirement.Name -PassThru -ErrorAction Ignore
                if (-not $alreadyLoaded) {
                    Install-Module -AllowClobber -Force -Name $requirement.Name -Scope CurrentUser
                    $alreadyLoaded = Import-Module -Name $requirement.Name -PassThru -ErrorAction Ignore
                    Write-Host "Installed $($alreadyLoaded.Name) for $($file.FullName)"
                } else {
                    Write-Host "Already loaded $($alreadyLoaded.Name) for $($file.FullName)"
                }
            }
            $title = $file.Name -replace '\..+?\.ps1$' -replace 'index'
            . $file            
        }
    }

    if ($null -eq $Output) {
        continue nextFile
    }

    # If we're outputting to html, let's do a few things:
    if ($outFile -match '\.html?$') {
        if (
            $outFile.Name -notmatch 'index\.html?$' -and 
            $permalink -eq 'pretty'
        ) {            
            $outFile = $outFile -replace '\.+?\.html$', '/index.html'            
        }

        # If the output has outerXML
        if ($output.OuterXml) {
            # we'll put it in inline
            $output = $output.OuterXml
        }

        # * If the output is does not have an <html> tag,
        if (-not ($output -match '<html')) {
            # we'll use a layout script.
            $fileRoot = $file.FullName | Split-Path
            while ($fileRoot) {
                $layoutPath = Join-Path $fileRoot 'layout.ps1'
                if (Test-Path $layoutPath) {
                    $output = $output | . $layoutPath
                    break
                }
                $fileRoot = $fileRoot | Split-Path
            }            
        }        
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
        $output > $outFile
        if ($?) {
            Get-Item -Path $outFile
        }
    }
}

$end = [datetime]::Now
Write-Host "File completed in $($end - $start)"
