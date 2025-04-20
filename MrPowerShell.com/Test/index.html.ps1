@'
<div id="RandomBuildNumber"></div>
<script>
const response = fetch('index.json')
document.getElementById('RandomBuildNumber').innerText = await response.json()
</script>
'@

