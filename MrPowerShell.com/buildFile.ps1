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
    
    # If we don't have a layout for this directory
    if (-not $layoutAtPath[$fileRoot]) {
        # go up until we find one.
        while ($fileRoot) {
            $layoutPath = Join-Path $fileRoot 'layout.ps1'
            # once we do
            if (Test-Path $layoutPath) {
                # set it in the hashtable
                $layoutAtPath[$fileRoot] = $layoutPath
                break # and take a break.
            }
            $fileRoot = $fileRoot | Split-Path
        }
    }

    # If we have a layout for this directory, we'll use it.
    if ($layoutAtPath[$fileRoot]) {
        # all we need to do is set the alias to it.
        Set-Alias layout $layoutAtPath[$fileRoot]
    }

    $Page = [Ordered]@{}

    $Output = $Content = switch ($file.Extension) {
        # If it's a markdown file, we'll convert it to HTML.
        '.md' {
            $title = $Page['title'] = $file.Name -replace '\.md$' -replace 'index'
            $outFile = $file.FullName -replace '\.md$', '.html'
            $yamlHeader = $file | yaml_header
            if ($yamlHeader -is [Collections.IDictionary]) {
                foreach ($keyValue in $yamlHeader.GetEnumerator()) {
                    $page[$keyValue.Key] = $keyValue.Value
                }
            }
            $file | from_markdown |
                layout
        }
        # If it's a typescript file, we'll compile it to JS.
        '.ts' {
            $outFile = $file.FullName -replace '\.ts$', '.js'
            tsc $file.FullName -module es6 -target es6
        }
        # If it's a powershell file, we'll probably run it.
        '.ps1' {
            # Unless the name is not like *.someExtension.ps1
            if ($file.Name -notlike '*.*.ps1') {
                continue nextFile
            }
            # Get the script command
            $scriptCmd = Get-Command -Name $file.FullName
            # and install any requirements it has.
            $scriptCmd | InstallRequirement
            # Extract the title from the name of the file.
            $title = $Page['title'] = $file.Name -replace '\..+?\.ps1$' -replace 'index'
            . $file
        }
    }

    # If we don't have output,
    if ($null -eq $Output) {
        continue nextFile # continue to the next file.
    }

    # If we're outputting markdown, and it's not yet HTML
    if ($outFile -match '\.md$' -and $output -notmatch '<html') {
        $outputAsMarkdown = @($output) -join [Environment]::NewLine
        $Output = $outputAsMarkdown | from_markdown | layout
    }

    # If we're outputting to html, let's do a few things:
    if ($outFile -match '\.html?$') {
        if ($outFile.Name -notmatch 'index\.html?$' -and  $permalink -eq 'pretty') {
            $outFile = $outFile -replace '\.+?\.html$', '/index.html'
        }

        # If the output has outerXML
        if ($output.OuterXml) {
            # we'll put it in inline
            $output = $output.OuterXml
        }

        # * If the output is does not have an <html> tag,
        if (-not ($output -match '<html')) {
            # we'll use the layout.            
            $output = $output | layout            
        }        
    }

    # If the output is json, and it's not yet json
    if ($outFile -match '\.json$' -and $output -isnot [string]) {
        # make it json
        $output = $output | ConvertTo-Json -Depth 10
    }
    
    # If the the output is XML,
    if ($output -is [xml]) {
        # save it
        $output.Save($outFile)
        # and if that worked,
        if ($?) {
            # output the file.
            Get-Item -Path $outFile
        }
    }
    # If the output was a series of fileInfo objects
    elseif ($outputFiles = foreach ($out in $Output) 
    {
        if ($out -is [IO.FileInfo]) {
            $out
        }
    }) {
        # just output them directly.
        $outputFiles
    } else {
        # otherwise, save it to a file.
        $output > $outFile
        # and if that worked,
        if ($?) {
            # output the file.
            Get-Item -Path $outFile
        }
    }
}

# we're done building files.
$end = [datetime]::Now
# so let everyone know how long it took.
Write-Host "File completed in $($end - $start)"
