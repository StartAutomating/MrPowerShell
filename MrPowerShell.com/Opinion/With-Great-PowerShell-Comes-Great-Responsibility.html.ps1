<#
.SYNOPSIS
    With Great PowerShell
.DESCRIPTION
    With Great PowerShell Comes Great Responsibility
.NOTES
    # With Great PowerShell

    ## With Great PowerShell Comes Great Responsibility

    ### Domain Admin Demigods

    Imagine you're a domain admin.

    You've worked long and hard.  
    
    You know how to script anything and everything in short order.

    You've made your job easy, and you've got scripts that can wipe a workstation in six seconds flat.

    Imagine you are a domain admin demigod, with the access rights that entails.

    You know you're good.  You're master of your domain.

    > What happens when you make a little mistake?
    
    Just once, you flash a password into a file or onscreen in a meeting.

    If anyone is lucky enough to grab that credential, they can take you and your automation to town.

    You may find it is your own workstation that is wiped in six seconds flat.

    You may find just how quickly your company no longer requires your services.  But enough about you.
    
    What happens to all of the people whose data leaked beause you could get to anything in seconds?

    What if you were the domain admin of a healthcare company?

    Or a financial instituion?

    Or a government organization?

    Your little mistake could cost you your job, and it could cost many other people far more than that.

    # With Great PowerShell Comes Great Responsibility

    ![With Great Power comes Great Responsibility](https://media1.tenor.com/m/l0X1K-08TpAAAAAC/aunt-may-with-great-power-comes-great-responsibility.gif)

    This is _not_ a joke.  This is serious, and occasionally deadly.

    This saying is designed to be easy to remember and to remind all of us who are gifted with technology.

    _**Ethics Matter**_.

    Like it or not, you have an ethical responsibility to everyone impacted by your work.

    You might not be a superhero, but please don't be an accidental supervillain.

    If you are entrusted with secrets that could harm others, you _must be responsible_.

    Don't like it?  Please let someone else do the job.
    
    Don't want it?  Plenty of work doesn't need to run as admin.

    ### Ethical Computing

    What does this mean?

    * It means be aware of security.    
    * It means guarding secrets well.
    * It means be aware of your software's impacts.
    * It means minimizing your risks.
    * It means speaking up about problems.
    * It means fighting to fix problems.
    * It means knowing how you can help.
    * It means knowing what can hurt.

    Most of all, ethical computing means

    * **_never try to harm_**

    You may have the access rights to commit unspeakable evils.

    You should never set out to do harm.

    You should understand who could get hurt, and how.

    You should be compassionate.
    
    You should be sensible.
    
    You should have character.

    You should act ethically.

    You should not be a superhero.

    You should not be a douchebag, either.

    The soul you save may be your own.

    Hope this helps,

    James
#>

Push-Location $psScriptRoot

#region Article
$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File
$title = $myHelp.Synopsis
$description = $myHelp.description.text -join [Environment]::NewLine

if ($page -isnot [Collections.IDictionary]) {
    $page = [Ordered]@{}
}

$page.title = $title
$page.description = $description

$markdown = $myHelp.alertset.alert.text -join [Environment]::NewLine 

$markdown > ($MyInvocation.MyCommand.Name -replace '(?:\.html)?\.ps1$', '.md')
"<style>"
"article { width: 120ch; margin-left:auto;margin-right:auto; }"
"article img { display: block; width: 50%; margin-left: auto; margin-right:auto; }"
"</style>"
"<article>"
$markdown | 
    ConvertFrom-Markdown | 
    Select-Object -expand html
"</article>"
#endregion Article

#region View Source
"<details id='view-source'>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>"
[Web.HttpUtility]::HtmlEncode("$($MyInvocation.MyCommand.ScriptBlock)")
"</code></pre>"
"</details>"
#endregion View Source

Pop-Location
