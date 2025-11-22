param([string]$Variant)
$title = "Resume"
$description = "My Long Professional History"
$myResume = ./MyResume @PSBoundParameters
$myResume.ToJson() > ./My.Resume.json
if (-not $variant) {

    foreach ($variant in 'DevOps', 'Cybersecurity', 'Full Stack', 'Design Engineering') {
        $variantResume = . ./MyResume.ps1 @PSBoundParameters -Variant $variant
        $variantResume | ../layout > "$($Variant -replace '\s').html"
    }
    
}
$myResume