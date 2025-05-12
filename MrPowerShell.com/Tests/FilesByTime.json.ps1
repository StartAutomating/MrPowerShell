#requires -Module ugit
$gitLog = git log -Statistics
foreach ($entry in $gitLog) {
    foreach ($change in $entry.Changes) {
        $change | 
            Add-Member -MemberType NoteProperty -Name 'CommitDate' -Value $entry.CommitDate -Force -PassThru
    }
}
