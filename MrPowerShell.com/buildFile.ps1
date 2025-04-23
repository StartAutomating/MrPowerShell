param(
[Parameter(ValueFromPipeline)]
[IO.FileInfo]
$File
)

Set-Alias layout "$pwd/layout.ps1"

$permalink = 'pretty'

$start = [datetime]::Now

:nextFile foreach ($file in $input) {
    $outFile = $file.FullName -replace '\.ps1$'
    $Output = switch ($file.Extension) {
        '.md' {
            $title = $file.Name -replace '\.md$' -replace 'index'
            $outFile = $file.FullName -replace '\.md$', '.html'
            (ConvertFrom-Markdown -Path $file.FullName).Html |
                layout
        }
        '.ps1' {
            if ($file.Name -notmatch '\..+?\.ps1$') {
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

        # If the output is XML
        if ($output -is [xml]) {
            # we'll put it in inline, minus the XML declaration.
            $output = $output.OuterXml -replace '<?xml.+?>'
        }

        # * If the output is does not have an <html> tag,
        if (-not ($output -match '<html')) {
            # we'll use the layout script.
            $output = $output | layout
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
