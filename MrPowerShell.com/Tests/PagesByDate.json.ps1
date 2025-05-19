#requires -Module ugit
$gitLog = git log -Statistics
$htmlOverTime = [Ordered]@{}
foreach ($entry in $gitLog) {
    foreach ($change in $entry.Changes) {
        if ($change.FilePath -match '^\.') { continue }
        if ($change.FilePath -notmatch '\.(?>html|md)') { continue }
        if ($htmlOverTime.ContainsKey($change.FilePath)) {
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
