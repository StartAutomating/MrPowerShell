#requires -Module oEmbed
./index.json.ps1 |    
    ForEach-Object { 
        Get-OEmbed -Url $_.YouTubeUrl -MaxHeight 1280 -MaxWidth 720
    } | 
    Select-Object -ExpandProperty Html