#requires -Module ugit
$gitLog = git log -Statistics
Push-Location ($PSScriptRoot | Split-Path)
$htmlOverTime = [Ordered]@{}
foreach ($entry in $gitLog) {
    foreach ($change in $entry.Changes) {
        if ($change.FilePath -match '^\.') { continue }
        if ($change.FilePath -notmatch '\.(?>html|md)') { continue }
        if ($htmlOverTime[$change.FilePath]) {
            continue
        }
        if (-not (Test-Path $change.FilePath)) {
            continue
        }
        $htmlOverTime[$change.FilePath] = [Ordered]@{
            FilePath = $change.FilePath
            CommitDate = $entry.CommitDate
            CommitMessage = $entry.CommitMessage
        }
    }
}
$htmlOverTime
Pop-Location
