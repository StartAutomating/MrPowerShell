# Filters are PowerShell functions designed to quickly process pipeline input.

# This file contains filters that are useful throughout the build.

#region PowerShell Specific Filters
filter InstallRequirement {
    <#
    .SYNOPSIS
        Installs a module if it is not already loaded.
    .DESCRIPTION
        Installs a PowerShell module if it is not already loaded.    
    #> 
    $requirementName = $_
    if ($requirementName -is [Management.Automation.ExternalScriptInfo]) {
        $requirementName.ScriptBlock.Ast.ScriptRequirements.RequiredModules.Name | 
            InstallRequirement
        return
    }
    $alreadyLoaded = Import-Module -Name $requirementName -PassThru -ErrorAction Ignore -Global
    # If they're not already loaded, we'll install them.
    if (-not $alreadyLoaded) {
        Install-Module -AllowClobber -Force -Name $requirementName -Scope CurrentUser
        $alreadyLoaded = Import-Module -Name $requirementName -PassThru -ErrorAction Ignore -Global
        if ($file.FullName) {
            Write-Host "Installed $($alreadyLoaded.Name) for $($file.FullName)"
        }        
    } elseif ($file.FullName) {
        Write-Host "Already loaded $($alreadyLoaded.Name) for $($file.FullName)"
    }
}
#endregion PowerShell Specific Filters

#region Special Filters
filter content {
    $Content
}

filter now {
    [DateTime]::Now
}

filter utc_now {
    [DateTime]::UtcNow
}

filter today {
    [DateTime]::Today
}

filter yaml_header_pattern {
    [Regex]::new('
(?<Markdown_YAMLHeader>
(?m)\A\-{3,}                      # At least 3 dashes mark the start of the YAML header
(?<YAML>(?:.|\s){0,}?(?=\z|\-{3,} # And anything until at least three dashes is the content
))\-{3,}                          # Include the dashes in the match, so that the pointer is correct.
)
','IgnoreCase, IgnorePatternWhitespace')
}

filter yaml_header {
    $in = $_
    if ($in -is [IO.FileInfo]) {
        $in | Get-Content -Raw | yaml_header
        return
    }
    foreach ($match in (yaml_header_pattern).Matches("$in")) {
        $match.Groups['YAML'].Value | from_yaml
    }    
}

filter from_yaml {
    $in = $_
    "YaYaml" | InstallRequirement
    $in | ConvertFrom-Yaml
}

filter strip_yaml_header {
    $in = $_
    if ($in -is [IO.FileInfo]) {
        $in | Get-Content -Raw | strip_yaml_header
        return
    }
    $in -replace (yaml_header_pattern)
}

filter from_markdown {
    $in = $_
    if ($in -is [IO.FileInfo]) {
        $in | Get-Content -Raw | from_markdown
        return
    }    
    @(
        $in | 
            strip_yaml_header | 
                ConvertFrom-Markdown |
                    Select-Object -ExpandProperty Html
    ) -replace 'disabled="disabled"'
}


#endregion Special Filters

#region Liquid Compatibility Filters

# Some filters are here for compatibility with Liquid templating.
# This is not meant to be a complete set of liquid filters.
# Feel free to add your own.

#region Date Filters
filter date {
    $in = $_
    if ($in -isnot [DateTime]) {
        $in = $in -as [DateTime]
    }
    if (-not $in) { return}
    $in.ToString("$args")
}

filter date_to_iso8601 {
    $in = $_
    if ($in -isnot [DateTime]) {
        $in = $in -as [DateTime]
    }
    if (-not $in) { return}
    $in.ToString('s')
}

filter date_to_rfc2822 {
    $in = $_
    if ($in -isnot [DateTime]) {
        $in = $in -as [DateTime]
    }
    if (-not $in) { return}
    $in.ToString('r')
}
#endregion Date Filters

#region String Filters

filter base64_decode {    
    $outputEncoding.GetString([Convert]::FromBase64String("$_"))    
}
filter base64_encode {    
    [Convert]::ToBase64String($outputEncoding.GetBytes("$_"))
}

filter capitalize {
    $string = "$_" -replace '^\s+'
    $string.Substring(0,1).ToUpper() + $string.Substring(1)
}

filter newline_to_br {
    $_ -replace '(?>\r\n|\n)', '<br/>'
}

filter downcase {
    "$_".ToLower()
}

filter escape {
    [Web.HttpUtility]::HtmlEncode("$_")
}

filter strip {
    $_ -replace '^\s+' -replace '\s+$'
}
filter strip_html {    
    $_ -replace '<[^>]+>'
}

filter strip_newlines {
    $_ -replace '(?>\r\n|\n)', ' '
}

filter url_encode {
    [Web.HttpUtility]::UrlEncode("$_")
}

filter url_decode {
    [Web.HttpUtility]::UrlDecode("$_")
}

filter xml_escape {
    [Security.SecurityElement]::Escape("$_")
}

filter upcase {
    "$_".ToUpper()
}
#endregion String Filters



#endregion Liquid Compatibility Filters