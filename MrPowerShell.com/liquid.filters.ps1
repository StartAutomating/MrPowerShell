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
