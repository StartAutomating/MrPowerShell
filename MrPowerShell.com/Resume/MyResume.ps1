if ($PSScriptRoot) { Push-Location $psScriptRoot }

. $psScriptRoot/JsonResume.ps1

$Basics = @{
    Name    = "James Brundage"
    Label   = "Prolific Programmer"
    Summary = "Experienced software developer with a passion for building innovative solutions."
    Website = "https://MrPowerShell.com"
}

$Work = @{
    Name = "LoanDepot (thru Ascendion)"
    Position = "Senior DevOps Engineer"
    StartDate = "2024-06"
    EndDate = "2025-07"
    Summary = "Improved platform and devops practices for LoanDepot's cloud infrastructure"
    Highlights = @(
        "Created tooling to migrate 400+ service accounts to Group Managed Service Accounts (GMSAs)",
        "This tooling helped avoid hundreds of hours of work each year as passwords no longer need to be rotated manually",
        "Increased quality of Kubernetes deployments by implementing rules with Rego",
        "This helped catch configuration issues before they reached production, and prevent drift in Kubernetes.",
        "Improved reliability of SQL operations by implementing quality gates in Azure DevOps",
        "This provided an approval and audit process for database changes, improving security and reliability."
    )
}, 
@{
    Name = "Aveva (thru Cognizant)"
    Position = "Senior DevOps Engineer"
    StartDate = "2023-10"
    EndDate = "2019-09"
    Summary = "Improved cloud infrastructure, monitoring, and CI/CD processes"
    Highlights = @(
        "Developing tooling to migrate TFS workflows to Azure DevOps pipelines",
        "This reduced the cost of migration of thousands of workflows by several orders of magnitude.",
        "Implemented new CI/CD pipelines using Azure DevOps.",
        "This reduced deployment times and improved consistency across environments.",
        "Led and trained virtual team of 14 engineers to improve internal monitoring with PowerShell",
        "This enabled end to end organization awareness thru Grafana and Azure DevOps."
    )
}, 
@{
    Name = "Microsoft (thru MBO Partners)"
    Position = "Senior Software Developer Engineer"
    StartDate = "2019-06"
    EndDate = "2023-06"
    Summary = "Developed the Azure Resource Manager Template Toolkit"
    Highlights = @(
        "Designed and developed a best practices toolkit for Azure Resource Manager templates.",
        "This reduced the time and cost for Azure Marketplace publishers to validate their templates.",
        "Worked closely with the Azure team to help codify best practices for Azure Resource Manager templates.",
        "This helped improve the Azure ecosystem by codifying guidance and providing compliance tooling.",
        "Developed a PowerShell module and custom testing framework to validate Azure Resource Manager templates.",
        "This provided a consistent and automated way to validate templates against best practices.",
        "Implemented over 50 complex best practices enforcement rules.",
        "This helped reduce error rates throughout the industry."
    )
},
@{
    Name = "Microsoft (thru Start-Automating)"
    Position = "Senior Security Development Engineer"
    StartDate = "2018-04"
    EndDate = "2019-04"
    Summary = "Developed security automation for the Azure Security Center"
    Highlights = @(
        "Developed a PowerShell module to help investigate security incidents in Azure",
        "Created internal web infrastructure to organize and visualize incident investigations.",
        "This helped reduce investigation times for security incidents by ~20%",
        "Created automation for internal security tooling to enable cross-referencing of security data.",
        "This helped improve the accuracy and speed of security investigations."
    )
},
@{
    Name = "Reliance Networks (thru Start-Automating)"
    Position = "Senior Software Developer"
    StartDate = "2018-03"
    EndDate = "2019-03"
    Summary = "Overhauled the data aggregation of every real estate listing in the US."
    Highlights = @(
        "Overhauled the data aggregation of every real estate listing in the US.",
        "This reduced total intake time from ~6 days to ~15 minutes, enabling near real-time updates.",
        "Created efficient ETL architecture to process millions of listings.",
        "This reduced infrastructure costs from `$20,000 per month to `$250 per month, eliminating 98% of infrastructure costs."
    )
},
@{
    Name = "Microsoft (thru Wipro)"
    Position = "Senior Software Developer Engineer"
    StartDate = "2016-07"
    EndDate = "2018-01"
    Summary = "Improved Intune internal automation"
    Highlights = @(
        "Overhauled internal automation for the deployment and management of the Intune service.",
        "Set up Just Enough Automation (JEA) to allow for secure, delegated administration of the Intune service.",
        "Developed a PowerShell module to automate the deployment of Intune service components.",
        "Established secure KeyVault use practices for storing sensitive information.",
        "This reduced incidents due to human error, and reduced liability exposure."
    )
},
@{
    Name = 'National Life Insurance (thru NTT Data)'
    Position = 'Senior DevOps Engineer'
    StartDate = '2014-09'
    EndDate = '2015-06'
    Summary = 'Improved internal automation and DevOps practices, and trained offshore support teams.'
    Highlights = @(
        "Developed PowerShell tooling to deploy and automate the management of the National Life Insurance infrastructure.",
        "Trained offshore support teams from junior to associate level in PowerShell and DevOps practices.",
        "This led to improved IT readiness and reduced personnel costs.",
        "Assisted in the parallelization of hedging automation, to improve the bottom line.",
        "Migrated scheduling from Control-M to Task Scheduler, improving security, reliability, and compliance."
    )
},
@{
    Name = "JPMorgan Chase (thru HP)"
    Position = "Senior Operations Engineer"
    StartDate = "2014-07"
    EndDate = "2014-12"
    Summary = "Rolled out the deployment of secure printing systems for JPMorgan Chase"
    Highlights = @(
        "Developed automation to deploy mass rollout of Phraos secure printing systems across the company",
        "Created tools to audit and report on the utilization of secure printing systems.",
        "This helped reduce exposure of sensitive documents and PII.",
        "Worked with the JPMorgan Chase team to ensure compliance with security policies."
    )
},
@{
    Name = "Microsoft (thru Start-Automating)"
    Position = "Senior Software Developer Engineer"
    StartDate = "2012-10"
    EndDate = "2013-10"
    Summary = "Developed internal monitoring for Office365"
    Highlights = @(
        "Developed a framework for monitoring the health of Office365 servers and services.",
        "Collected thousands of data points per hour from tens of thousands of servers.",
        "This provided increased visibility into the health of Office365 for management and engineering teams.",
        "Developed new techniques for parallel data collection and analysis.",
        "Created a PowerShell module to automate the collection and analysis of monitoring data.",
        "Created web dashboards to visualize the health of Office365 services.",
        "This helped improve the reliability and performance of Office365."
    )
},
@{
    Name = "Microsoft (thru Start-Automating)"
    Position = "Senior Software Developer Engineer"
    StartDate = "2011-06"
    EndDate = "2012-05"
    Summary = "Automated the deployment of BPOS, the predecessor to Office 365"
    Highlights = @(
        "Worked with management to identify key pain points in the BPOS deployment process."
        "Automated the deployment of Sharepoint Online and Exchange using PowerShell."
        "Reduced new customer deployment time from ~7 days to under an hour"
        'Automated the work of multiple manual teams, resulting in cost savings of approximately $250,000 per month, or $2.5 million dollars per year.'
    )
},,
@{
    Name = "Microsoft (thru Start-Automating)"
    Position = "Senior Software Developer Engineer"
    StartDate = "2010-10"
    EndDate = "2012-01"
    Summary = "Developed a compact virtualization toolkit for the Zero Day Attack Lab"
    Highlights = @(        
        "Created a rapidly deployable toolkit of endless variations of Windows VMs and additional software."
        "Developed significant expertise in Hyper-V and application virtualization."
        "Created a series of Hyper-V differential disks containing patches until a point in time."
        "This toolkit could be deployed by security researchers across the world in minutes."
        "The toolkit was used to rapidly identify the impact of zero-day attacks on Windows systems."        
        "This work helped secure the windows ecosystem against emerging threats."
    )
},
@{
    Name = "Microsoft"
    Position = "Senior Software Developer Engineer in Test"
    StartDate = "2006-01"
    EndDate = "2010-05"
    Summary = "Tested and evangelized the PowerShell language."
    Highlights = @(
        "Helped develop the PowerShell language and its features.",
        "Created and maintained test suites for PowerShell.",
        "Pioneered the use of PowerShell in User Interfaces",
        "This helped prove the versatility and power of PowerShell as a scripting language.",
        "Pioneered web development with PowerShell and ASP.net",
        "This helped create an ecosystem of web applications built on PowerShell.",
        "Contributed to the PowerShell community by writing blog posts and articles.",        
        "Participated in the development of PowerShell 2.0 and 3.0."
    )
},
@{
    Name = "Microsoft (thru Volt Technical Services)"
    Position = "Software Developer Engineer in Test"
    StartDate = "2005-01"
    EndDate = "2006-01"
    Summary = "Overhauled security testing for WMI and sheparded IPV6 support within Management Division components (WMI, TaskScheduler, Event Log) "
    Highlights = @(
        "Overhauled security testing for Windows Management Infrastructure to use automated testing."
        "Improved guidance on DCOM security settings for WMI, resulting in improved security for the windows ecosystem."
        "Drove IPv6 support within the Management Division of Microsoft prior to Vista RC1, to meet DOD requirements."
        "Assisted partner teams in implementing WMI providers, enabling remote management of virtualization."
        "Performance tested WMI and Event Log to ensure stability and reliability under heavy load."
        "This helped improve the long term security of the windows ecosystem."        
    )
},
@{
    Name = 'Synesthetic'
    Position = 'Graphics Developer / VJ'
    StartDate = "2000-10"
    EndDate = "2005-06"
    Highlights = @(
        "Developed realtime video mixing (VJ) software suite for live performances.",
        "Created visual effects and animations for live shows.",
        "Worked with various artists to create unique visual experiences."
    )
},
@{
    Name = 'Filmcritic.com'
    Position = 'Staff Writer and secondary webmaster'
    Highlights = @(
        'Wrote hundreds of movie reviews for Filmcritic.com from 1996 to 2001.'
        'Created and maintained web infrastructure for ~4,000,000 monthly users.'
    )
}

$skills = @{
    name = "PowerShell"
    level = "Master (18+ years)"
}, @{
    name = "HTML"
    level = "Master (30+ years)"
}, @{
    name = "JavaScript"
    level = "Expert (30+ years)"
}, @{
    name = "CSS"
    level = "Expert (30+ years)" 
}, @{
    name = "C# / .Net Framework"
    level = "Expert (~20 years)"
}, @{
    name = "C++"
    level = "Expert (~25 years)"
}, @{
    name = 'P/Invoke'
    level = 'Expert (~15 years)'
}, @{
    name = 'XML'
    level = "Expert (~25 years)"
}, @{
    name = 'xPath'
    level = "Expert (~20 years)"
}, @{
    name = "SQL"
    level = "Expert (~20 years)"
}, @{
    name = "NoSQL"
    level = "Expert (~15 years)"
}, @{
    name = "Azure"
    level = "Expert (~15 years)"
}, @{
    name = "Azure DevOps"
    level = "Expert (~10 years)"
}, @{
    name = "Azure Resource Manager"
    level = "Expert (~6 years)"
}, @{
    name = "Git"
    level = "Expert (~15 years)"
}, @{
    name = "GitHub Workflows"
    level = "Expert (~10 years)"
}, @{
    name = "GitHub Actions"
    level = "Expert (~10 years)"
}, @{
    name = 'Regular Expressions'
    level = "Expert (~10 years)"
}, @{
    name = "Docker"
    level = "Intermediate (~5 years)"
}, @{
    name = "Kubernetes"
    level = "Intermediate (~3 years)"
}, @{
    name = "At Protocol"
    level = "Intermediate (~2 years)"
}, @{
    name = "Python"
    level = "Intermediate (~5 years)"
}

$languages = @{
    language = "PowerShell"
    fluency = "Expert"
}, @{
    language = "HTML"
    fluency = "Expert"
}, @{
    language = "JavaScript"
    fluency = "Expert"
}, @{
    language = "CSS"
    fluency = "Expert"
}, @{
    language = "C#"
    fluency = "Expert"
}, @{
    language = "C++"
    fluency = "Expert"
}, @{
    language = "Python"
    fluency = "Intermediate"
}, @{
    language = "SQL"
    fluency = "Expert"
}


$interests = @{
    name = "Automation"
}, @{
    name = "Open Source Software"
}, @{
    name = "Artificial Intelligence"
}, @{
    name = "Cloud Computing"
}, @{
    name = "Software Development"
}, @{
    name = "DevOps Practices"
}, @{
    name = "Cybersecurity"    
}, @{
    name = "PowerShell Community"
}, @{
    name = '3D Printing'
}

$myResume = JsonResume @Basics -Work $work -Skill $skills -Language $languages -Interest $interests

$myResume = $myResume | 
    Add-Member ToHtml -MemberType ScriptMethod -Value {
        $attributes = [Ordered]@{
            'class' = 'json-resume'    
        }
        $attributeString = @($attributes.GetEnumerator() | ForEach-Object { "$($_.Key)='$($_.Value)'" }) -join ' '
        "<div $attributeString>"    
            "<h2>"
            if ($this.Website) {
                "<a href='$($this.Website)'>$($this.Name)</a>"
            } else {
                # Otherwise, just use the name.
                "$($this.Name)"
            }
            "</h2>"
            "<h3 class='json-resume-label'>$([Web.HttpUtility]::HtmlEncode($this.Label))</h3>"
            "<h4 class='json-resume-summary'>$([Web.HttpUtility]::HtmlEncode($this.summary))</h4>"
            "<h3>Work</h3>"
            "<ul class='json-resume-work'>"
            foreach ($work in $this.Work) {
                "<li class='json-resume-work-item'>"
                "<h4 class='json-resume-work-position'>$([Web.HttpUtility]::HtmlEncode($work.position))</h4>"
                "<h5 class='json-resume-work-company'>$([Web.HttpUtility]::HtmlEncode($work.company))</h5>"
                "<p class='json-resume-work-dates'>$([Web.HttpUtility]::HtmlEncode($work.startDate)) - $([Web.HttpUtility]::HtmlEncode($work.endDate))</p>"
                if ($work.summary) {
                    "<p class='json-resume-work-summary'>$([Web.HttpUtility]::HtmlEncode($work.summary))</p>"
                }
                if ($work.highlights) {
                    "<ul class='json-resume-work-highlights'>"
                    foreach ($highlight in $work.highlights) {
                        "<li>$([Web.HttpUtility]::HtmlEncode($highlight))</li>"
                    }
                    "</ul>"
                }
                "</li>"
            }
            "</ul>"
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