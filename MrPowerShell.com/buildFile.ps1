param(
[Parameter(ValueFromPipeline)]
[IO.FileInfo]
$File
)

$permalink = 'pretty'
$start = [datetime]::Now
$layoutAtPath = [Ordered]@{}
$layoutAtPathParameters = [Ordered]@{}
$allFiles = @($input)
if (-not $allFiles) { return}

$FileNumber = 0
$TotalFiles = $allFiles.Length
$progressId = Get-Random
:nextFile foreach ($file in $allFiles) {
    $outFile  = $file.FullName -replace '\.ps1$'
    $fileRoot = $file.Directory.FullName
    # Get the file name by removing the extension.
    $fileName = $file.Name.Substring(0, $file.Name.Length - $file.Extension.Length)
    # Generate a file date by:
    $fileDate = $fileName -replace 
            # * Remove any non-digit (except colon, dash, and underscore, and Z)
            '[^\d:-_Z]' -replace
                 # * Trim leading punctuation, and trailing punctuation (and Z), 
                '^\p{P}+' -replace '[-Z]+$' -replace 
                # * replace underscores with colons, and try to cast to `[DateTime]`
                '_',':' -as [DateTime]

    Write-Progress -Id $progressId -Status "Building Pages" "$($file.Name) " -PercentComplete ((++$FileNumber / $TotalFiles) * 100)
    # Initialize the page object
    $Page = [Ordered]@{
        # anything in MetaData should be rendered as <meta> tags in the <head> section.
        MetaData = [Ordered]@{}
    }

    if ($fileDate) {
        $page.Date = $fileDate
    }
    
    # If we don't have a layout for this directory
    if (-not $layoutAtPath[$fileRoot]) {
        # go up until we find one.
        while ($fileRoot) {
            $layoutPath = Join-Path $fileRoot 'layout.ps1'
            # once we do
            if (Test-Path $layoutPath) {
                # set it in the hashtable
                $layoutAtPath[$fileRoot] = $ExecutionContext.SessionState.InvokeCommand.GetCommand($layoutPath, 'ExternalScript')
                
                break # and take a break.
            }
            $fileRoot = $fileRoot | Split-Path
        }
    }

    $layoutParameters = [Ordered]@{}
    # If we have a layout for this directory, we'll use it.
    if ($layoutAtPath[$fileRoot]) {
        # all we need to do is set the alias to it.
        Set-Alias layout $layoutAtPath[$fileRoot]

        # check for any parameters from the layout script, in the page and site configuration.
        $layoutParameters = $layoutAtPathParameters[$fileRoot] = [Ordered]@{}
        :nextParameter foreach ($parameter in $layoutAtPath[$fileRoot].Parameters.GetEnumerator()) {
            $potentialType = $parameter.Value.ParameterType
            foreach ($PotentialName in 
                @($parameter.Value.Name;$parameter.Value.Aliases) -ne ''
            ) {
                if ($page[$potentialName] -and $page[$potentialName] -as $potentialType) {
                    $layoutParameters[$potentialName] = $page[$potentialName]
                    continue nextParameter
                }
                elseif ($site[$potentialName] -and $site[$potentialName] -as $potentialType) {
                    $layoutParameters[$potentialName] = $site[$potentialName]
                    continue nextParameter
                }
            }
        }
    }

    # We want to support data files for each potential page
    $dataFilePattern =
        # They are named the same as the file, but with an additional extension.
        # The extension is either json, psd1, or yaml.
        "^$([Regex]::Escape($file.Name))\.(?>json|psd1|ya?ml)$"

    # Find any data files
    $dataFiles =
        Get-ChildItem -Path $file.Directory.FullName |
        Where-Object Name -match $dataFilePattern

    # If we have a data file, we'll use it to set the page configuration.
    foreach ($dataFile in $dataFiles) {
        switch ($dataFile.Extension) {
            '.json' {
                $pageConfig = Get-Content -Path $dataFile.FullName -Raw | ConvertFrom-Json
                foreach ($property in $pageConfig.psobject.properties) {
                    $Page[$property.Name] = $property.Value
                }
            }
            '.psd1' {
                $pageConfig = Import-LocalizedData -FileName $dataFile.Name -BaseDirectory $file.Directory.FullName
                foreach ($property in $pageConfig.GetEnumerator()) {
                    $Page[$property.Key] = $property.Value
                }
            }
            '.yaml' {
                $pageConfig = Get-Item $dataFile.FullName | from_yaml
                foreach ($property in $pageConfig.GetEnumerator()) {
                    $Page[$property.Key] = $property.Value
                }
            }
        }
    }

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
            $file | from_markdown | layout @layoutParameters
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
            $scriptCmd | RequireModule
            # Extract the title from the name of the file.
            $title = $Page['title'] = $file.Name -replace '\..+?\.ps1$' -replace 'index'
            
            #region Map File Parameters to Page and Site configuration
            $FileParameters = [Ordered]@{}
            :nextParameter foreach ($parameter in $scriptCmd.Parameters.GetEnumerator()) {
                $potentialType = $parameter.Value.ParameterType
                foreach ($PotentialName in 
                    @($parameter.Value.Name;$parameter.Value.Aliases) -ne ''
                ) {
                    if ($page[$potentialName] -and $page[$potentialName] -as $potentialType) {
                        $FileParameters[$potentialName] = $page[$potentialName]
                        continue nextParameter
                    }
                    elseif ($site[$potentialName] -and $site[$potentialName] -as $potentialType) {
                        $FileParameters[$potentialName] = $site[$potentialName]
                        continue nextParameter
                    }
                }
            }
            . $file @FileParameters
        }
    }

    # If we don't have output,
    if ($null -eq $Output) {
        continue nextFile # continue to the next file.
    }

    # If we're outputting markdown, and it's not yet HTML
    if ($outFile -match '\.md$' -and $output -notmatch '<html') {
        $outputAsMarkdown = @($output) -join [Environment]::NewLine
        $Output = $outputAsMarkdown | from_markdown | layout @layoutParameters
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
            $output = $output | layout @layoutParameters
        }
    }    
    
    if ($output -is [Data.DataSet]) {
        switch -regex ($outFile) {
            '\.json$' {
                $jsonObject = [Ordered]@{}
                foreach ($table in $output.Tables) {
                    if (-not $table.TableName) { continue }
                    $jsonObject[$table.TableName] = $table | 
                        Select-Object -Property $($table.Columns.ColumnName) 
                }
                $jsonObject | 
                    ConvertTo-Json -Depth ($FormatEnumerationLimit * 2) |
                    Set-Content -Path $outFile
                
                if ($?) {
                    Get-Item -Path $outFile
                    continue nextFile
                }
                
            }
            '\.xml$' {
                $output.WriteXml("$outFile")
                if ($?) {
                    Get-Item -Path $outFile
                    continue nextFile
                }
            }
            '\.xsd$' {
                $output.WriteXmlSchema("$outFile")
                if ($?) {
                    Get-Item -Path $outFile
                    continue nextFile
                }
            }
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

Write-Progress -Id $progressId -Completed -Status "Building Pages" "$($file.Name) " 
# we're done building files.
$end = [datetime]::Now
# so let everyone know how long it took.
Write-Host "File completed in $($end - $start)"
