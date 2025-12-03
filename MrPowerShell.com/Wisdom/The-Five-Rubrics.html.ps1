<#
.SYNOPSIS
    The Five Rubrics
.DESCRIPTION
    Five Rubrics to help refine any idea or project.
.NOTES
    We have all have a good idea or two.  
        
    We engineers, and creatives, and leaders may have a few more than that.
    
    Intellectual professionals live and die by ideas.

    But what ideas are good?
    
    Why do some good ideas become industries, while others become hobbies?
    
    More mysteriously, why do good ideas often go nowhere?
    
    Ideas are like people.
    
    People may be good or bad, pretty or ugly, unique or mundane, but people are all affected by the people around them and the environment they are in.  
    
    Ideas often succeed or fail not because the idea is good or bad, but because of how it interacts with the surrounding conceptual landscape and the people who need to get the idea:
    
    * Can they get it?
    * What do they see it as?
    * Are other ideas in the landscape going to help or hurt it?
    
    
    Ironically, ideas often fail because they are not thoroughly thought thru.
    
    This is understandable.
    
    Good judgment comes fom understanding; understanding comes fom curiosity, openness, introspection, and compassion.
    
    While all of these are virtues, they are generally in short supply.

    The Five Rubrics are designed to instill these virtues in an intellectual individual (at least for a short period of time).
    
    It poses questions that can help crush cloudy concepts early and sharpen smart ideas.

    Each Rubric is designed to answer one core question by making you think thru several others.

    There are no right or wrong answers.

    The goal is to make you think more deeply about your idea.

    ## The Idea Interrogator
 
    1. Can this Be Done?
    2. Who Needs It?
    3. Who Else Does It?
    4. What can they do about it?
    5. Who Do I Need To Know?
    6. How hard is it?
    7. When does it need to happen?
    8. When is it useless?
    9. Where is it useful?
    10. What am I missing?

    ## The Concept Checklist
    
    1. Why should I care?
    2. What's it called?
    3. What does it do?
    4. What's it like?
    5. How's it different?
    6. Is it new?
    7. Who's it for?
    8. Why should they care?
    9. How do I talk to them?
    10. How will they hear about it?

    ## The Workload Worksheet

    1. What's the goal?
    2. Why does it need to happen?
    3. How does it happen?
    4. What's the timefame?
    5. Is there enough room?
    6. Who do I need?
    7. What do I need?
    8. What's the bottleneck?
    9. What could go wrong?
    10. What's your backup plan?

    ## The Quality Quiz

    1. What is done?
    2. When is done?
    3. Why we're done?
    4. Is done forever?
    5. What can I do later?
    6. What needs to happen now?
    7. Why is this important?
    8. What makes it perfect?
    9. What makes it broken?
    10. What do I do when it breaks?

    ## The Pricing Primer

    1. How valuable is it?
    2. How valuable will it seem?
    3. What will it cost me to try?
    4. What does it cost me each time?
    5. Who helps sell it?
    6. What will they get?
    7. When will I lose money?
    8. When will I stop losing money?
    9. Are there competitors?
    10. Is cheaper better?

    ### Using the Rubrics

    These rubrics are best used introspectively.

    You can write down your thoughts, but you don't have to.

    You can pick and choose which of these questions are important to your idea, and how you feel about their answers.

    These are merely questions you or others might ask about your idea, designed to help refine your ideas and projects.

    I originally wrote these over a decade ago, and have sent them in emails time and again over the years to people pondering problems.

    Hopefully, The Five Rubrics will be useful to you.

    Hope this helps,

    James
.LINK
    https://MrPowerShell.com/Wisdom/The-Five-Rubrics
#>

#region Page Help
# Get my help
$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File

# My synopsis becomes the page title
$title = $myHelp.Synopsis
# and my description becomes the page description.
$description = $myHelp.Description.text -join [Environment]::NewLine
# My notes are in markdown.
$notes = $myHelp.alertset.alert.text -join [Environment]::NewLine

# If we have page metadata, copy title and description
if ($page -is [Collections.IDictionary]) {
    $page.Title = $title
    $page.Description = $description
}

# Make one big markdown out of our title, description, and notes
@"
# $($title)

## $($description)

$notes
"@ | 
    # convert it from markdown
    ConvertFrom-Markdown |
    # and output the HTML
    Select-Object -ExpandProperty Html
#endregion Page Help

#region View Source
"<hr/>"
"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"
#endregion View Source
