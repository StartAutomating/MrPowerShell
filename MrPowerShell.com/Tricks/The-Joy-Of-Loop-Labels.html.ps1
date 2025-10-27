<#
.SYNOPSIS
    The Joy Of Loop Labels
.DESCRIPTION
    Why you might want to use loop labels.
.NOTES
    [Loop labels](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_break?wt.mc_id=MVP_321542#using-a-labeled-break-in-a-loop) 
    are a powerful and underused part of many programming languages.

    In PowerShell, they take the form :name, and can come before any loop statement

    ~~~PowerShell
    :OneIn1kb foreach ($n in 1..1kb) { $n }
    ~~~

    Loops do not need to have labels, but I'm starting to think that it's pretty darn good practice to include them.

    Let's look at two major reasons for why:

    ### Performance

    Let's start with the _real_ reason most languages have loop labels of some form.

    Performance.

    Imagine we want to enforce multiple exclusions of some condition.

    Let's write it without loop labels first

    ~~~PowerShell
    foreach ($file in $files) {
        if ($exclude) {
            $included = $true
            foreach ($exclusion in $Exclude) {
                if ($file.FullName -like $exclusion) {
                    $included = $false                    
                }                        
            }
            if (-not $included) {
                break
            }
        }
        $file
    }
    ~~~

    There are actually two performance problems with this code.

    The first is that we are "over-looping" thru exclusions.

    After all, if the file is excluded, it's excluded.
    
    It does not matter if it is excluded because it matches five wildcards or one.

    That file is excluded.

    We can improve the code a little bit by breaking out of the inner loop.

    ~~~PowerShell
    foreach ($file in $files) {
        if ($exclude) {
            $included = $true
            foreach ($exclusion in $Exclude) {
                if ($file.FullName -like $exclusion) {
                    $included = $false
                    break
                }                        
            }
            if (-not $included) {
                break
            }
        }
        $file
    }
    ~~~
    

    This code is a little faster, but it still feels messy.
    
    See how we're using one loop to break out of another?

    We're also using just a few extra cycles to set a variable, update it, check it, and jump out of the main loop.

    Now let's see how we can get a faster and cleaner exclusion with a loop label:

    ~~~PowerShell
    :nextFile foreach ($file in $files) {
        if ($exclude) {            
            foreach ($exclusion in $Exclude) {
                if ($file.FullName -like $exclusion) {
                    continue nextFile
                }                        
            }            
        }
        $file
    }
    ~~~

    Isn't that much cleaner?

    Now the moment we find a file has been excluded, we continue onto the next file.

    Less code, fewer variables, and better performance!

    There's one more benefit this brings, and it's the real reason I felt compelled to write this article.

    ### Readability

    Instead of such a short loop, let's imagine a bigger one.

    Let's imagine we're doing tons of things in each step of the loop, including a few nested loops.

    ~~~PowerShell
    foreach ($file in $files) {
        
        DoStuff        
        
        DoMoreStuff
        DoMoreStuff
        DoMoreStuff
        
        DoEvenMoreStuff
        DoEvenMoreStuff
        DoEvenMoreStuff
        DoEvenMoreStuff

        foreach ($line in Get-Content $file) {
            DoSomethingWithEachLine
        }

        if ($file.Length % 2) {
            continue
        }
    }
    ~~~

    The further down we want to break or continue out of the loop, the harder this gets to follow.
    
    The more inner loops we have, the harder this gets to follow.

    When we're trying to read our code and figure out how it's working, this isn't exactly helpful.

    We have to keep thinking "where am I?" and "where is this going?"

    If we gave things a label instead, it becomes a lot more easy to see:

    ~~~PowerShell
    :nextFile foreach ($file in $files) {
        
        DoStuff        
        
        DoMoreStuff
        DoMoreStuff
        DoMoreStuff
        
        DoEvenMoreStuff
        DoEvenMoreStuff
        DoEvenMoreStuff
        DoEvenMoreStuff

        foreach ($line in Get-Content $file) {
            DoSomethingWithEachLine
        }

        if ($file.Length % 2) {
            continue nextFile
        }
    }
    ~~~

    Because we have a logical loop label, instead of a raw `break` or `continue`, we know where we are going.
    
    The larger your loop, the more useful this will be.

    The more inner loops you have, the more useful loop labels will be.

    As a good rule of thumb, I think you should consider adding loop labels when:

    * It makes the code quicker.
    * You use loops within loops.
    * The loop is more than a dozen lines long.

    Hopefully this short post helps everyone see the Joy of Loop Labels.

    Hope this Helps!

    ---
#>
param()

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


#region View Source 
# Provide the source within a `<details>` element.
"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"
#endregion View Source
