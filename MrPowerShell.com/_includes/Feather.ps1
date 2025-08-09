param(
[string]
$Icon = 'chevron-right'
)

if (-not $script:FeatherIconCache) {
    $script:FeatherIconCache = [Ordered]@{}
}
$icon = $icon.ToLower() -replace '\.svg$'

if (-not $script:FeatherIconCache[$icon]) {
    $script:FeatherIconCache[$icon] = Invoke-RestMethod "https://cdn.jsdelivr.net/gh/feathericons/feather@latest/icons/$Icon.svg"
}

$script:FeatherIconCache[$icon].OuterXml

 
