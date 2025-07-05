if (-not $Page) {
    $Page = [Ordered]@{}
}
$Page.Title = 'HTMX 101'
$Page.Description = 'Tests that HTMX buttons work as expected with the main area'
$Page.UseHtmx = $true

@"
<button hx-get="../" hx-select='.main' class="btn primary">
Click Me To Load Main Area
</button>
"@