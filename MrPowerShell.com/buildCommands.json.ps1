[Ordered]@{
    Applications = Get-Command -CommandType Application | select Name, source
    Functions = Get-Command -CommandType Function | select Name, Module
    Cmdlets = Get-Command -CommandType Cmdlet | select Name, Module
    Aliases = Get-Command -CommandType Alias | select Name, ResolvedCommand
} | ConvertTo-Json -Depth 3

