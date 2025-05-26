function Get-GitSparse
{
    [Alias('git.sparse','GitSparse')]
    param(
        [Parameter(Mandatory)]
        [uri]
        $Repository="https://github.com/bluesky-social/atproto/",

        [string]
        $Path,

        [string[]]
        $Pattern=@('lexicons/**/**.json'),

        [Alias('AsHashTable')]
        [switch]
        $AsDictionary
    )

    begin {
        filter AsDictionary {
            $outputDictionary = [Ordered]@{}
            foreach ($file in Get-ChildItem -Recurse -File) {
                $relativePath = $file.FullName -replace 
                    "^$([Regex]::Escape("$pwd"))" -replace 
                    '\\', '/' -replace 
                    '/{1,}', '/' -replace
                    '^/+' 
                $outputDictionary["/$relativePath"] = 
                    switch -regex ($file.Extension) {
                        '\.json$' {
                            Get-Content -Path $file.FullName -Raw | ConvertFrom-Json
                        }
                        '\.jsonl$' {
                            Get-Content -Path $file.FullName | ConvertFrom-Json
                        }
                        '\.ps1$' {
                            $ExecutionContext.SessionState.InvokeCommand.GetCommand($file.FullName, 'ExternalScript')
                        }
                        '\.(?:ps1)?xml$' {
                            (Get-Content -Path $file.FullName -Raw) -as [xml]
                        }
                        '\.psd1' {
                            Import-LocalizedData -FileName $file.Name -BaseDirectory $file.Directory.FullName
                        }
                        default {
                            Get-Content -Path $file.FullName -Raw
                        }
                    }
            }
            
            $outputDictionary
        }
    }

    process {
        if (-not $PSBoundParameters['Path']) {
            $Path = $PSBoundParameters['Path'] = $Repository.Segments[-1] -replace '\.git$'
        }
        if (Test-Path $path) { 
            if ($AsDictionary) {
                Push-Location $path
                AsDictionary
                Pop-Location
            } else {
                Get-ChildItem -Recurse -File -Path $Path
            }
                        
            return 
        }
        $null = git clone --depth 1 --no-checkout --sparse --filter=tree:0 $Repository $Path
        Push-Location "./$Path"
        $null = git sparse-checkout set --no-cone @Pattern
        $null = git checkout
        if ($AsDictionary) {
            AsDictionary
        } else {
            Get-ChildItem -Recurse -File -Path $Path
        }
        Pop-Location        
    }
}

<#

git clone --depth 1 --no-checkout --sparse --filter=tree:0 https://github.com/bluesky-social/atproto/
Push-Location ./atproto
git sparse-checkout set --no-cone lexicons/**/**.json
git checkout
Pop-Location

#>


