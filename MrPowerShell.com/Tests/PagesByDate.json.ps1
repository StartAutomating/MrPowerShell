#requires -Module ugit
$gitLog = git log -Statistics
Push-Location (git rev-parse --show-toplevel)
$htmlOverTime = [Ordered]@{}
foreach ($entry in $gitLog) {
    foreach ($change in $entry.Changes) {
        if ($change.FilePath -match '^\.') { continue }
        if ($change.FilePath -notmatch '\.(?>html|md)') { continue }        
        if (-not (Test-Path $change.FilePath -ErrorAction Ignore)) {
            continue
        }
        if (-not $htmlOverTime[$change.FilePath]) {
            $htmlOverTime[$change.FilePath] = @()
        }

        $htmlOverTime[$change.FilePath] += [Ordered]@{            
            CommitDate = $entry.CommitDate
            CommitMessage = $entry.CommitMessage
            LinesChanged = $change.LinesChanged
            LinesInserted = $change.LinesInserted
            LinesDeleted = $change.LinesDeleted
        }        
    }
}
$htmlOverTime
Pop-Location
