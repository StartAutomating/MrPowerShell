@'
<div id="RandomBuildNumber"></div>
<script type='module'>
const response = await fetch('index.json')
document.getElementById('RandomBuildNumber').innerText = await response.json()
</script>
'@

