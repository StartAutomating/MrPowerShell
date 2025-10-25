function Get-JsonResume
{
    <#
    .SYNOPSIS
        Gets a JSON Resume 
    .DESCRIPTION
        Gets a JSON resume from a URI, file path, and allows 
    .LINK
        https://jsonresume.org/
    #>
    [CmdletBinding(DefaultParameterSetName='JsonResume')]
    [Alias('JsonResume')]
    param(
    # The uri of the JSON resume
    [Parameter(Mandatory,ParameterSetName='ResumeUrl',ValueFromPipelineByPropertyName)]    
    [Alias('ResumeUri')]
    [uri]
    $ResumeUrl,

    # The file path of the JSON resume
    [Parameter(Mandatory,ParameterSetName='FilePath',ValueFromPipelineByPropertyName)]
    [Alias('File', 'ResumeFile','FullName')]
    [string]
    $FilePath,

    # Get the JSON Resume schema
    [Parameter(Mandatory,ParameterSetName='GetSchema',ValueFromPipelineByPropertyName)]    
    [switch]
    $GetSchema,

    # The name on the resume.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('LegalName')]
    [string]
    $Name,

    # The label on the resume.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('ResumeLabel','PersonalLabel','Title','JobTitle','Position')]
    [string]
    $Label,

    # The summary or brief description.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Description')]
    [string]
    $Summary,

    # Any phone number of contact number.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Telephone','Phone','ContactNumber')]
    [string]
    $PhoneNumber,

    # Any email address of contact number.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('ContactEmail')]
    [string]
    $EmailAddress,

    # Any website or URL of contact number.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Uri','ContactUrl','WebAddress')]
    [string]
    $Website,

    # Any social media profiles for the resume owner.
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateScript( {
        foreach ($required in 'network','url') {
            if (-not $_.$required) { 
                throw "Social media entries must have a '$required' property."        
            }
        }
        return $true            
    })]
    [PSObject[]]
    $SocialMedia,

    # Any basic information about the resume owner.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Basics','BasicInfo')]
    [PSObject]
    $Basic,    
    
    # Any relevant work experience.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [ValidateScript( {
        foreach ($required in 'name','position') {
            if (-not $_.$required) { 
                throw "Must have a '$required' property."
            }
        }
        return $true            
    })]
    [Alias('WorkExperience','WorkHistory')]    
    [PSObject[]]
    $Work,

    # Any relevant volunteer experience.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('VolunteerExperience','VolunteerHistory','Volunteering')]
    [PSObject[]]
    $Volunteer,

    # Your educational history.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('EducationHistory','Schooling','SchoolHistory','AcademicHistory')]
    [PSObject[]]
    $Education,    
    
    # Your skills.  Listing skills improve your chances of being found in searches.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('Skills')]
    [PSObject[]]
    $Skill,

    # Your projects.  Listing projects can help demonstrate your skills.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('Projects')]
    [PSObject[]]
    $Project,

    # Your languages.  Listing languages lets employers know what languages you can speak or program in.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('Languages')]
    [PSObject[]]
    $Language,

    # Your interests.  Listing interests can help show your personality and cultural fit.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('Interests')]
    [PSObject[]]
    $Interest,

    # Your references.  Listing references can help validate your skills and experience.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('References')]
    [PSObject[]]
    $Reference,

    # Your awards.  Listing awards can help demonstrate your achievements.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('Awards')]
    [PSObject[]]
    $Award,

    # Your publications.  Listing publications can help demonstrate your expertise.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('Publications')]
    [PSObject[]]
    $Publication,

    # Your certifications.  Listing certifications can help demonstrate your qualifications.
    [Parameter(ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('Certifications')]
    [PSObject[]]
    $Certification,

    # An entire JSON resume object.  If this is provided, other parameters will add or update sections of the resume.
    [Parameter(Position=0,ParameterSetName='JsonResume',ValueFromPipelineByPropertyName)]
    [Alias('JsonResume')]
    [PSObject]
    $Resume
    )

    if ($GetSchema) {
        return Invoke-RestMethod 'https://raw.githubusercontent.com/jsonresume/resume-schema/refs/heads/master/schema.json'
    }

    $gotAResume = 
        switch ($PSCmdlet.ParameterSetName) {
            'ResumeUrl' {
                Invoke-RestMethod -Uri $ResumeUrl
            }
            'FilePath' {
                Get-Content -Path $FilePath -Raw | ConvertFrom-Json 
            }
            'JsonResume' {
                if (-not $Resume) {
                    [PSCustomObject][Ordered]@{}
                }
                else {
                    $resume
                }                
            }
        }

    $resume = $gotAResume
    if (-not $resume) { return }
            
    if ($Basic) {
        if (-not $Resume.basics) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'basics' -Value $basic
        } else {
            $resume.basics = $basic
        }        
    }

    if (-not $resume.basics) {
        $Resume | Add-Member -MemberType NoteProperty -Name 'basics' -Value ([PSCustomObject]@{}) -Force
    }

    if ($Name) {
        if (-not $Resume.basics.name) {
            $Resume.basics | Add-Member -MemberType NoteProperty -Name 'name' -Value $Name -Force
        } else {
            $Resume.basics.name = $Name
        }
    }

    if ($Label) {
        if (-not $Resume.basics.label) {
            $Resume.basics | Add-Member -MemberType NoteProperty -Name 'label' -Value $Label -Force
        } else {
            $Resume.basics.label = $Label
        }
    }

    if ($PhoneNumber) {
        if (-not $Resume.basics.phone) {
            $Resume.basics | Add-Member -MemberType NoteProperty -Name 'phone' -Value $PhoneNumber -Force
        } else {
            $Resume.basics.phone = $PhoneNumber
        }
    }
    if ($EmailAddress) {
        if (-not $Resume.basics.email) {
            $Resume.basics | Add-Member -MemberType NoteProperty -Name 'email' -Value $EmailAddress -Force
        } else {
            $Resume.basics.email = $EmailAddress
        }
    }
    if ($Website) {
        if (-not $Resume.basics.url) {
            $Resume.basics | Add-Member -MemberType NoteProperty -Name 'url' -Value $Website -Force
        } else {
            $Resume.basics.url = $Website
        }
    }

    if ($Summary) {
        if (-not $Resume.basics.summary) {
            $Resume.basics | Add-Member -MemberType NoteProperty -Name 'summary' -Value $Summary -Force
        } else {
            $Resume.basics.summary = $Summary
        }
    }

    if ($SocialMedia) {
        if (-not $Resume.basics.profiles) {
            $Resume.basics | Add-Member -MemberType NoteProperty -Name 'profiles' -Value @() -Force
        }
        $Resume.basics.profiles += $SocialMedia
    }

    if ($Work) {
        if (-not $Resume.work) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'work' -Value @() -Force
        }
        $Resume.work += foreach ($workExperience in $work) {
            if ($workExperience.Company -and -not $workExperience.Name) {
                $workExperience | Add-Member -MemberType NoteProperty -Name 'name' -Value $workExperience.Company -Force
            }
            elseif ($workExperience.CompanyName -and -not $workExperience.Name) {
                $workExperience | Add-Member -MemberType NoteProperty -Name 'name' -Value $workExperience.CompanyName -Force
            }
            $workExperience
        }
    }

    if ($Volunteer) {
        if (-not $Resume.volunteer) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'volunteer' -Value @() -Force
        }
        $Resume.volunteer += $Volunteer
    }

    if ($Education) {
        if (-not $Resume.education) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'education' -Value @() -Force
        }
        $Resume.education += $Education
    }
    if ($Skill) {
        if (-not $Resume.skills) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'skills' -Value @() -Force
        }
        $Resume.skills += $Skill
    }
    if ($Project) {
        if (-not $Resume.projects) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'projects' -Value @() -Force
        }
        $Resume.projects += $Project
    }
    if ($Language) {
        if (-not $Resume.languages) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'languages' -Value @() -Force
        }
        $Resume.languages += $Language
    }
    if ($Interest) {
        if (-not $Resume.interests) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'interests' -Value @() -Force
        }
        $Resume.interests += $Interest
    }
    if ($Reference) {
        if (-not $Resume.references) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'references' -Value @() -Force
        }
        $Resume.references += $Reference
    }
    if ($Award) {
        if (-not $Resume.awards) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'awards' -Value @() -Force
        }
        $Resume.awards += $Award
    }
    if ($Publication) {
        if (-not $Resume.publications) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'publications' -Value @() -Force
        }
        $Resume.publications += $Publication
    }
    if ($Certification) {
        if (-not $Resume.certifications) {
            $Resume | Add-Member -MemberType NoteProperty -Name 'certifications' -Value @() -Force
        }
        $Resume.certifications += $Certification
    }
    if ($Resume.pstypenames -notcontains 'JsonResume') {
        $Resume.pstypenames.insert(0,'JsonResume')
    }
    $Resume        
}
