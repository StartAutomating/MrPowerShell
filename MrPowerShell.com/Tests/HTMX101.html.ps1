if (-not $Page) {
    $Page = [Ordered]@{}
}
$Page.Title = 'HTMX 101'
$Page.Description = 'Tests that HTMX buttons work as expected with the main area'
$Page.UseHtmx = $true

@"
<button hx-get="../Gists" hx-select='.main' class="btn primary">
Load Gists
</button>
"@