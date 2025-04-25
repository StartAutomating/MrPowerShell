$svgXml = Invoke-RestMethod -uri 'https://raw.githubusercontent.com/feathericons/feather/refs/heads/main/icons/github.svg'
$svgXml.svg.setAttribute('class','foreground-stroke')
$svgXml.Save("$psScriptRoot/GitHub.svg")
