<#
.SYNOPSIS
    The Compassionate Razor
.DESCRIPTION
    Never Attribute to Malice That Which Can Adequately Be Explained By Humanity
.NOTES
    I don't know about you, but I find good adages to be really useful.

    The best turns of phrase condense a little of wisdom into a simple short saying.

    For example, a lot of people are familiar with [Occam's Razor](https://en.wikipedia.org/wiki/Occam%27s_razor).
    Most commonly you'll heart as something like:
    > "The Simplest Explanation is Most Often the Correct One."

    Another one most people might know is [Murphy's Law](https://en.wikipedia.org/wiki/Murphy's_law).
    You might have heard this as:
    > "If Anything Can Go Wrong, it Will."

    One a lot of nerds know is [Hanlon's Razor](https://en.wikipedia.org/wiki/Hanlon%27s_razor).
    It's commonly put as:
    > "Never Attribute to Malice That Which Can Adequately Explained By Stupidity."

    As someone who has been around the block a few times in life, I find each of these adages pretty applicable.

    And, yet, I also find that Hanlon's Razor is a little too malicious itself (or, according to it's own adage, too stupid).

    People, as a general rule, do not like being called stupid.  This is true regardless of their level of intelligence.

    People, as a general rule, make mistakes.  This is true regardless of their level of intelligence.
    
    Many of life's social difficulties arise because of these two truths.

    I find it pretty helpful to switch Hanlon's Razor up a bit.

    ### The Compassionate Razor:

    > "Never Attribute To Malice That Which Can Adequately Be Explained By Humanity"

    #### What This Means

    You can presume the worst about people if you want.  I would not recommend it.

    In my experience, very few people try to be the villain, and very few people try to be stupid.

    If I we feel someone is wrong, we have a few options:

    1. Think they're trying to do wrong
    2. Think they're wrong and don't know it
    3. Think they're human beings that make mistakes

    I prefer option three.

    #### Why This Helps

    I find being compassionate about someone's humanity makes them more likely to work on being wrong.

    Think about this like the [Golden Rule](https://en.wikipedia.org/wiki/Golden_Rule).

    Imagine you were wrong.

    Would you rather:

    1. Be accused of being a villain?
    2. Be told you were stupid?
    3. Be compassionately confronted with the wrong?
    
    I prefer option three.

    I suspect you do, too.

    #### Please Be Compassionate

    Many mistakes don't happen because people want to be mean or malicious.

    Many mistakes don't happen because people are inherantly stupid.

    Many mistakes happen when we are:

    * Distracted
    * Overloaded
    * Angry
    * Scared
    * Panicked
    * Foolish
    * Sick
    * Tired        
    * Hungry
    * Poor

    We all make mistakes, for we are all human.

    If we want a world with fewer mistakes, please be compassionate.

    > "Never Attribute To Malice That Which Can Adequately Be Explained By Humanity"

    Hope this Helps,

    James
#>
param()

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

$markdown = @"
# $($title)

## $($description)

$notes
"@

# Write our markdown into a local file.
$markdown > (
    $MyInvocation.MyCommand.Source -replace '\.html.ps1$', '.md'
)
"<article>"
$markdown | 
    # convert it from markdown
    ConvertFrom-Markdown |
    # and output the HTML
    Select-Object -ExpandProperty Html
"</article>"
#endregion Page Help

#region View Source
"<hr/>"
"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"
#endregion View Source

