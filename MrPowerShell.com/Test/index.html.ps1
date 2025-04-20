@'
<div id="RandomBuildNumber"></div>
<script type='module'>
const response = fetch('index.json')
document.getElementById('RandomBuildNumber').innerText = await response.json()
</script>
'@

