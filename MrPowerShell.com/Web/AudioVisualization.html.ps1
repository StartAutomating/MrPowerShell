$title = "Audio Visualizer"

$setPalette = "
<script>
    function SetPalette() {
        var palette = document.getElementById('palette')
        if (! palette) {
            palette = document.createElement('link')
            palette.rel = 'stylesheet'
            palette.id = 'palette'
            document.head.appendChild(palette)
        }
        var selectedPalette = document.getElementById('SelectPalette').value
        palette.href = 'https://cdn.jsdelivr.net/gh/2bitdesigns/4bitcss@latest/css/' + selectedPalette + '.css'
    }
</script>
"

$paletteSelector = @"
<select id='SelectPalette' onchange='SetPalette()'>
$(foreach ($paletteName in (Invoke-RestMethod https://4bitcss.com/Palette-List.json)) {
    "<option value='$([Web.HttpUtility]::HtmlAttributeEncode($paletteName))'>$([Web.HttpUtility]::HtmlEncode($paletteName))</option>"
})
</select>
"@


$setPalette

$html = @"
<div style="text-align:center;width:100%;height:100%">
    <input type="file" id="audioFile" multiple="true" />
    <br/>
    $paletteSelector
    <br/>
    <audio controls="true" autoplay="true" id="audio"></audio>
    <br/>    
    <canvas id="oscilloscope" width='1920' height='320' ></canvas>
    <br/>
    <canvas id="audiobars" width="1920" height="320"></canvas>
</div>

<script>    
var audio = document.getElementById('audio');
var audioLoader = document.getElementById('audioFile');
var playlistFiles = []
var playlistIndex = 0;
audioLoader.addEventListener('change', (e) => {
    var reader = new FileReader();
    reader.onload = (event) => {
        audio.src = event.target.result;
    }
    
    for (var i = 0; i < e.target.files.length; i++) {
        playlistFiles.push(e.target.files[i])            
    }
    playlistIndex = 0;
    reader.readAsDataURL(e.target.files[playlistIndex])
}, false);

audio.addEventListener('playing', (e) => {
    ShowOscilliscope();
}, false);
audio.addEventListener('ended', (e) => {
    if (playlistIndex < playlistFiles.length - 1) {
        var reader = new FileReader();
        reader.onload = (event) => {
            audio.src = event.target.result;
            audio.play();
        }
        playlistIndex++;
        reader.readAsDataURL(playlistFiles[playlistIndex])
        
    }        
}, false);


// Get a canvas defined with ID "oscilloscope"
const oscilloscopeCanvas = document.getElementById("oscilloscope");
const oscilloscopeCanvas2d = oscilloscopeCanvas.getContext("2d");

const audiobarsCanvas = document.getElementById("audiobars");
const audiobarsCanvas2d = audiobarsCanvas.getContext("2d");

async function ShowOscilliscope() {
    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    const analyser = audioCtx.createAnalyser();
    analyser.fftSize = 2048;
    const bufferLength = analyser.frequencyBinCount;
    
    const dataArray = new Uint8Array(bufferLength);
    const frequencyArray = new Uint8Array(bufferLength);
    source = audioCtx.createMediaElementSource(document.getElementById("audio"));
    
    // Connect the source to be analysed
    source.connect(analyser);
    analyser.connect(audioCtx.destination);
    

    // draw an oscilloscope of the current audio source
    function draw() {
        requestAnimationFrame(draw);

        analyser.getByteTimeDomainData(dataArray);
        analyser.getByteFrequencyData(frequencyArray);

        let backgroundColor = getComputedStyle(audiobarsCanvas).getPropertyValue('--background')
        if (backgroundColor == '') {
            backgroundColor = '#FFFFFF'
        }

        let foregroundColor = getComputedStyle(audiobarsCanvas).getPropertyValue('--foreground')
        if (foregroundColor == '') {
            foregroundColor = '#000000'
        }

        const barsWidth = audiobarsCanvas.scrollWidth
        const barsHeight = audiobarsCanvas.scrollHeight
        const scopeWidth = oscilloscopeCanvas.scrollWidth
        const scopeHeight = oscilloscopeCanvas.scrollHeight
        
        audiobarsCanvas2d.fillStyle = backgroundColor
        audiobarsCanvas2d.fillRect(0, 0, barsWidth, barsHeight)

        oscilloscopeCanvas2d.fillStyle = backgroundColor
        oscilloscopeCanvas2d.fillRect(0, 0, scopeWidth, scopeHeight)

        oscilloscopeCanvas2d.lineWidth = 2;
        oscilloscopeCanvas2d.strokeStyle = foregroundColor;

        oscilloscopeCanvas2d.beginPath();

        const sliceWidth = (scopeWidth * 1.0) / bufferLength;
        const barWidth = (barsWidth * 1.0) / bufferLength;
        var barHeight = 0;
        let x = 0;

        for (let i = 0; i < bufferLength; i++) {
            const v = dataArray[i] / 128.0;
            const y = (v * scopeHeight) / 2;

            if (i === 0) {
                oscilloscopeCanvas2d.moveTo(x, y);
            } else {
                oscilloscopeCanvas2d.lineTo(x, y);
            }

            x += sliceWidth;
        }

        oscilloscopeCanvas2d.lineTo(scopeWidth, scopeHeight / 2);
        oscilloscopeCanvas2d.stroke();

        x = 0;

        for (let i = 0; i < bufferLength; i++) {
            barHeight = frequencyArray[i] / 2;
            audiobarsCanvas2d.fillStyle = foregroundColor;
            audiobarsCanvas2d.fillRect(x, barsHeight - barHeight / 2, barWidth, barHeight);
            x += barWidth + 1;
        }
    }
    draw();
}
</script>
"@
$html
"<pre><code class='language-PowerShell'>"
[Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock)
"</code></pre>"