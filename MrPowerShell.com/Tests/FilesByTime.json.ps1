#requires -Module ugit
$gitLog = git log -Statistics
foreach ($entry in $gitLog) {
    foreach ($change in $entry.Changes) {
        if ($change.FilePath -match '^\.') { continue }
        $change | 
            Add-Member -MemberType NoteProperty -Name 'CommitDate' -Value $entry.CommitDate -Force -PassThru |        
            Add-Member -MemberType NoteProperty -Name 'CommitMessage' -Value $entry.CommitMessage -Force -PassThru
    }
}
