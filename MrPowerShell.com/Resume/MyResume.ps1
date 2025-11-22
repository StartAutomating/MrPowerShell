param([string]$Variant)
if ($PSScriptRoot) { Push-Location $psScriptRoot }

. $psScriptRoot/JsonResume.ps1


$variants = @{
    "DevOps" = "Git", "Azure\s?DevOps", "CI/CD", "Workflow", "PowerShell"
    "Cybersecurity" = "Security", "Threat", "Attacks", "Secure"
    "Full Stack" = "Server Side", "Backend", "HTML", "CSS", "JavaScript"
    "Design Engineering" = "HTML", "CSS", "JavaScript"
}

$variantPatterns = @{}

foreach ($variantName in $variants.Keys) {
    $variantPatterns[$variants[$variantName] -join '|'] = $variantName
}

$workHistory = ./WorkHistory

$Basics = @{
    Name    = "James Brundage"
    Label   = "Prolific Programmer and Platform Engineer, and Evangelist"
    Summary = "
Experienced and passionate engineer.

Excellent at reducing costs thru automation.

Current a 2nd year Microsoft Most Valued Professional.

Jack of all trades, master of PowerShell.
"
    Website = "https://MrPowerShell.com"
}

$skills = ./Skills.ps1
$languages = ./Languages.ps1
$interests = ./Interests.ps1

$resumeParameters = [Ordered]@{}

if ($Variant) {
    $variantKeywords = $variants[$Variant]
    $resumeParameters.Work = @(:nextWork foreach ($work in $workHistory) {        
        foreach ($highlight in $work.highlights) {
            foreach ($keyword in $variantKeywords) {
                if (-not $keyword) { continue }
                if ($highlight -match "[\s\p{P}]$keyword[\s\p{P}]") {
                    $work
                    continue nextWork
                } 
            }            
        }        
    })
} else {
    $resumeParameters.Work= $workHistory
}

$myResume = JsonResume @Basics @resumeParameters -Skill $skills -Language $languages -Interest $interests

$myResume = $myResume | 
    Add-Member ToHtml -MemberType ScriptMethod -Value {                
        "<div class='resume'>"    
            "<h2>"
            if ($this.basics.url) {
                "<a href='$($this.basics.url)'>$($this.basics.name)</a>"
            } else {
                # Otherwise, just use the name.
                "$($this.basics.name)"
            }
            "</h2>"            
            "<h3 class='resume-label'>$([Web.HttpUtility]::HtmlEncode($this.basics.Label))</h3>"
            "<h4 class='resume-summary'>
            $((ConvertFrom-Markdown -InputObject $this.basics.Summary).Html)
            </h4>"
            "<h3>Experience</h3>"
            "<ul class='resume-work'>"
            foreach ($work in $this.Work) {
                $startDateFriendly = if ($work.startDate -is [DateTime]) {
                    "{0:yyyy}-{0:MM}" -f $work.startDate
                } else {
                    $work.startDate
                }
                $endDateFriendly = if ($work.endDate -is [DateTime]) {
                    "{0:yyyy}-{0:MM}" -f $work.endDate
                } else {
                    $work.endDate
                }

                "<li class='resume-work-item'>"

                "<h4 class='resume-work-position'>$([Web.HttpUtility]::HtmlEncode($work.position))</h4>"
                "<h5 class='resume-work-company'>$([Web.HttpUtility]::HtmlEncode($work.name))</h5>"
                
                if ($startDateFriendly -and $endDateFriendly) {
                    "<p class='resume-work-dates'>$startDateFriendly - $endDateFriendly</p>"
                }
                
                if ($work.summary) {
                    "<p class='resume-work-summary'>$([Web.HttpUtility]::HtmlEncode($work.summary))</p>"
                }
                
                if ($work.highlights) {
                    "<ul class='resume-work-highlights'>"
                    foreach ($highlight in $work.highlights) {
                        "<li>$([Web.HttpUtility]::HtmlEncode($highlight))</li>"
                    }
                    "</ul>"
                }
                
                "</li>"
            }
            "</ul>"

            if ($this.Skills) {
                "<h3>Skills</h3>"
                @(
                    "|Skill|Level|"
                    "|-|-|"                
                    foreach ($skill in $this.Skills) {
                        "|$($skill.Name)|$($skill.Level)|"
                    }
                ) -join [Environment]::NewLine | ConvertFrom-Markdown |
                    Select-Object -ExpandProperty Html
            }

            if ($this.Languages) {
                "<h3>Languages</h3>"
                @(
                    "|Language|Fluency|"
                    "|-|-|"                
                    foreach ($skill in $this.Languages) {
                        "|$($skill.language)|$($skill.fluency)|"
                    }
                ) -join [Environment]::NewLine | ConvertFrom-Markdown |
                    Select-Object -ExpandProperty Html
            }
        "</div>"    
    } -Force -PassThru |
    Add-Member ScriptMethod ToString -Value {
        $this.ToHtml() -join [Environment]::NewLine
    } -Force -PassThru |
    Add-Member ScriptMethod ToJson -Value {
        ConvertTo-Json $this -Depth 10
    } -Force -PassThru

$myResume.ToJson() > ./My.Resume.json
$myResume