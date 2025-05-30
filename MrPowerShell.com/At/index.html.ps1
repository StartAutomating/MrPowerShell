@'
<div id="PostCount"></div>
<script type='module'>
import at from './at.js'
document.getElementById('PostCount').innerText = at()['app.bsky.feed.post'].length
</script>
'@


