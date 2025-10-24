<#
.SYNOPSIS
    The Power of Primes
.DESCRIPTION
    Why primes are pretty useful in programming
.NOTES
    Prime numbers are numbers that are not the product of two smaller numbers.

    Or, put more plainly, they are numbers that can only be divided by themselves or one.

    Prime numbers are particularly useful in programming, but it's not always obvious why or how.

    A lot of people might vaguely point towards cryptography as the prime real estate for prime utility.

    The thing of it is, if you're writing your own cryptography, you're probably doing it wrong.

    Let's talk about a more practical application of primes.

    ### Cicadas and Scheduling

    In North America there is a curious critter known as the [periodical cicaca](https://en.wikipedia.org/wiki/Periodical_cicadas).

    For the vast majority of their long lifespans, they live underground.
    
    Once every N years, they surface in mass to start the next generation.

    That N is a prime.

    Why?

    Cicadas come out en masse so that there are too many of them to eat.
    
    Millions of little critters have to have a perfectly timed multi-year internal clock in order to make this work.

    If two cicadas of different intervals produced offspring, their children might have a messed up internal clock, and come out of the ground at the worst time.

    So there's an evolutionary advantage to cicadas coming out in large batches, as long as another cicade brood isn't doing the same thing at the same time.

    Which brings us back to primes.

    Primes are relatively rare.

    So are products of primes (at least past the first few)

    Let's take two primes as an example.  
    
    Imagine one brood of cicadas came out every 11 years, and another brood came out every 13 years.
    
    We can find out how long it will take for these two broods to come out at the same time by simply multiplying the primes.

    ~~~PowerShell
    11 * 13 -eq 143
    ~~~

    So, with just two relatively low primes, we have an overlap every 143 years.

    This is how primes are most useful to programming: they rarely overlap.
    
    ### Sieve of Eratosthenes

    This has been known for much longer than computers have existed.

    Imagine we wanted to find prime numbers quickly.  
    
    We can do this by constructing a sieve that filters out any non-prime number.

    This is called the [Sieve of Eratosthenes](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes)

    Once we know 2 is prime, we know every other even number is not prime.

    Once we know 3 is prime, we know every third number is not prime.
    
    To quickly get prime numbers up to a point, we can use this little PowerShell function
    
    ~~~PowerShell
    # Calculate primes reasonably quickly with the Sieve of Eratosthenes
    # Pipe in any positive whole number to see if it is prime.
    filter prime {
        $in = $_
        if ($in -isnot [int]) { return }
        if ($in -eq 1) { return $in }
        if ($in -lt 1) { return}
        if (-not $script:PrimeSieve) {
            $script:PrimeSieve = [Collections.Queue]::new()
            $script:PrimeSieve.Enqueue(2)
        }


        if ($script:PrimeSieve -contains $in) { return $in}
        foreach ($n in $script:PrimeSieve) {
            if (($n * 2) -ge $in) { break }        
            if (-not ($in % $n)) { return }
        }
        $script:PrimeSieve.Enqueue($in) 
        $in
    }
    ~~~

    Let's find all the primes between 1 and 10000, and see how long it takes

    ~~~PowerShell
    $foundPrimesIn = Measure-Command { $primes = 1..10000 | prime  }
    
    $primes.Count
    ~~~

    For perspective, let's take the last two primes and multiply them, and see how long it takes for an overlap.

    ~~~PowerShell
    $primeProduct = $primes[-2] * $primes[-1]
    $primeProduct
    [TimeSpan]::FromSeconds($primeProduct)
    ~~~

    Even at one change a second, we will take a little over _3 years_ to overlap.

    Which highlights what primes are _really_ useful for in computing:

    Avoiding overlaps.

    ### Performance and Scheduling

    Imagine we want to design a system that's constantly checking for problems.

    We want the system to know about problems as soon as we can, but nobody's exactly sure how often they need to check for something.

    If we go around and ask our colleagues "how often should we can scan for this?", the response if often a shrug 🤷.

    Often, people will pick an arbitrary number that seems reasonable.  Let's say every 5 minutes, 10, or 15 minutes.

    Are we starting to see the problem here?

    Every 5 minutes, every computer in the cloud starts to collect stats and report them back.

    And we get a traffic jam.

    Every 10 minutes, more computers in the cloud collect more data, and our traffic jam gets worse.

    Every 15 minutes, even more computers collect even more data, and our traffic jam puts your average freeway to shame.

    Left to our own intuition, we create problems for ourselves and our organizations.

    Each individual query is small, but because we're doing so many at once, it can grind performance to a halt.

    By the way, this isn't a hypothetical.  
    
    Long long ago, the Office365 team asked me to make some monitoring software to help improve internal visibility into the datacenters.
    
    Everyone asked for 5, 10, or 15 minute intervals.  ~100 different metrics were collected from ~30000 machines.

    And the first time we tried it on everything, the traffic jam ensued.

    That's when I first realized the power of primes.

    I made three slight adjustments to the timeframes:

    * Every 5 minutes became every ~7 minutes
    * Every 10 minutes became every ~11 minutes
    * Every 15 minutes became every ~17 minutes

    Now, instead of having a traffic jam every 5 minutes, things smoothed out.

    * A small traffic jam would occur every ~77 minutes (7*11)
    * Another small traffic jam would occur every ~119 minutes (7*17) 
    * Another small traffic jam would occur at ~187 minutes (11*17)
    * All traffic could jam every ~1309 minutes (7*11*17)

    Note the tildas.

    The real trick came in by using prime intervals in both minutes and seconds, and using a random delay on the tasks to ensure they didn't all start at once.

    This took the system from something that could derail a datacenter to something that could monitor thousands of machines while barely impacting performance.

    This is the power of primes.

    Hope this helps!

    Please enjoy this list of primes, generated at build time.
#>


$myHelp = Get-Help $MyInvocation.MyCommand.ScriptBlock.File

$title = $myHelp.Synopsis
$description = $myHelp.Description.text -join [Environment]::NewLine
$notes = $myHelp.alertset.alert.text -join [Environment]::NewLine

if ($page -is [Collections.IDictionary]) {
    $page.Title = $title
    $page.Description = $description
}

ConvertFrom-Markdown -InputObject @"
# $($title)

## $($description)

$notes
"@ | 
    Select-Object -ExpandProperty Html


# Calculate primes reasonably quickly with the Sieve of Eratosthenes
# Pipe in any positive whole number to see if it is prime.
filter prime {
    $in = $_
    if ($in -isnot [int]) { return }
    if ($in -eq 1) { return $in }
    if ($in -lt 1) { return}
    if (-not $script:PrimeSieve) {
        $script:PrimeSieve = [Collections.Queue]::new()
        $script:PrimeSieve.Enqueue(2)
    }


    if ($script:PrimeSieve -contains $in) { return $in}
    foreach ($n in $script:PrimeSieve) {
        if (($n * 2) -ge $in) { break }        
        if (-not ($in % $n)) { return }
    }
    $script:PrimeSieve.Enqueue($in) 
    $in
}

$foundPrimesIn = Measure-Command { $primes = 1..10000 | prime  }
"<hr/>"
"<h3>Found $($primes.Count) primes less than 10000</h3>"
"<h4>In $($foundPrimesIn.TotalSeconds) seconds</h4>"
"<hr/>"
"<h3>List of Primes less than 10000</h3>"
"<pre><code>"
$primes -join [Environment]::NewLine
"</code></pre>"

"<details>"
"<summary>View Source</summary>"
"<pre><code class='language-powershell'>$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))</code></pre>"
"</details>"
