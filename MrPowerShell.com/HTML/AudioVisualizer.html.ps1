#requires -Module Turtle 

if (-not $Page) {
    $Page = [Ordered]@{}
}

$title = "Audio Visualizer"

$description = "A simple audio visualizer using the Web Audio API, made with PowerShell."

if ($Page) {
    $page.Title = $title
    $Page.Description = $description
    $Page.Image = "https://MrPowerShell.com/HTML/AudioVisualizer.png"
    # The page background is randomly selected during site configuration.    
}

$randomPalette = @"
<script>
function SetRandomPalette() {
    var SelectPalette = document.getElementById('SelectPalette')
    var randomNumber = Math.floor(Math.random() * SelectPalette.length);
    SelectPalette.selectedIndex = randomNumber
    SetPalette()
}
</script>
"@

$randomColor = @"
<script>
function SetRandomColor() {
    var SelectColor = document.getElementById('SelectColor')
    if (!SelectColor) { return }
    var randomNumber = Math.floor(Math.random() * SelectColor.length)
    SelectColor.selectedIndex = randomNumber
}
</script>
"@

$savePng = @"
<script>
function SavePNG(elementId) {
    var canvas = document.getElementById(elementId)
    var dataURL = canvas.toDataURL('image/png')
    var a = document.createElement('a')
    a.href = dataURL
    a.download = ```${elementId}.png``
    a.click()
    console.log('Saved PNG')
}
</script>
"@

$OnResize = '
<script>
function Resize() {    
    var visuals = document.getElementById("visuals")    
    var powerShellCode = document.getElementById("PowerShellCode")
    if (window.innerWidth) {        
        //visuals.width = window.innerWidth
        //visuals.height = window.innerHeight * 0.7
        powerShellCode.style.top = window.innerHeight
    } else {
        //visuals.width = screen.width
        //visuals.height = screen.height * 0.7
        powerShellCode.style.top = screen.height            
    }
        
    console.log(`Resized ${screen.width}x${screen.height}`)
}
window.addEventListener("resize", function() {
    Resize()
})
Resize()
</script>
'

$colorSelector = @"
<select id='SelectColor' selected='foreground'>
$(foreach ($colorName in 'foreground','red','green','blue','yellow','purple','cyan','brightBlue','brightRed','brightGreen','brightYellow','brightPurple','brightCyan') {
    "<option value='--$colorName'>$colorName</option>"    
})
</select>
"@

$randomPalette
$randomColor
$savePng


$Style = @"
.controlsGrid {
    position: fixed;
    gap: .42%;
    display: grid;
    text-align: center;
    align-items: center;    
    width:100vw;
    margin-left:auto;
    margin-right:auto;
    top: 75%;
    height:10vh;

}

.audioPlayer {
    width: 50%;
    margin-left: auto;
    margin-right: auto;
}

@media (orientation: portrait) {
    .controlsGrid { 
        top: 66%
    }
}

.overlay {
    z-index: 50
}

.controlsGrid button {
    max-width: 10vw
}

.visualsGrid {
    position: absolute;
    z-index: -1;
    top: 0;
    left: 0;
    display: grid;
    width: 100vw;
    height: 100vh;
}

.audioFieldset {
    display: grid;
    width: 24ch;
    grid-template-areas:
        'levelsAndPan'
        'rateAndPitch';
}

.colorFieldSet {
    width: 24ch;
}

.nowPlaying {
    display: grid;
    align-items: center
    grid-template-rows: 4;
    grid-template-areas:
        'playProgress'
        'playFile'
        'playControls';        
}

.playerProgress {
    grid-area: playProgress
}
.nowPlayingInput {
    grid-area: playFile
}


.rateAndPitch { grid-area: rateAndPitch; display: grid; }

.levelsAndPanGrid {
    display: grid;
    grid-area: 'levelsAndPan'
    text-align: center;
    width: 12ch;
    margin-left:auto;
    margin-right: auto;
    grid-template-areas: 
        'leftGain rightGain'
        'leftLabel rightLabel'
        'panInput panInput'
        'panLabel panLabel'
    ;
}

.leftGainInput { grid-area: leftGain }
.rightGainInput { grid-area: rightGain }
.leftLabel { grid-area: leftLabel; text-align: center; }
.rightLabel { grid-area: rightLabel; text-align: center; }

.showFieldSet { width: 24ch }

.panInput { 
    grid-area: panInput; 
    align-items: center;
    align-self: center;
    text-align: center; 
    width: 100%;
}
.panLabel { grid-area: panLabel; text-align: center; }

#visuals {
    width: 100vh;
    position: fixed;
    top: 0;
    left: 0;
    z-index: -10;
}
    
#PowerShellCode {
    top: 100vh;
    width: 100vw;
}

pre { text-align: left }

.verticalSlider{ writing-mode: vertical-rl;direction: rtl }

// .colorWheel { filter: url('#colorWheel'); }
// canvas { filter: url('#blurFilter'); }
// #background-svg { filter: url('#blurFilter') }
.audioControls { text-align: center}
"@

$svgFilters = @'
<!-- Generated with PSSVG 0.2.10 <https://github.com/StartAutomating/PSSVG> -->
<svg width='0%' height='0%' xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="colorWheel">
      <feColorMatrix type="hueRotate">
          <animate attributeName="values" values="0; 360" dur=".42s" repeatCount="indefinite" />
      </feColorMatrix>
      <feMorphology operator="dilate" radius="1" result="dilated">
        <animate attributeName="radius" values="0;42;0" dur="0.42s" repeatCount="indefinite"/>
      </feMorphology>
      <feMorphology operator="erode" radius="1" result="eroded">
        <animate attributeName="radius" values="0;42;0" dur="0.42s" repeatCount="indefinite"/>
      </feMorphology>      
      <feBlend mode="exclusion" in="SourceGraphic" in2="eroded" result="blendedEroded">        
        <animate attributeName="mode" values="screen;overlay;screen" dur="0.42s" repeatCount="indefinite"/>
      </feBlend>
      <feBlend mode="exclusion" in2="eroded" in="blendedEroded" />
  </filter>
  <filter id='erodeFilter'>
    <feMorphology in="SourceGraphic" operator="erode" radius="1" result="eroded">
        <animate attributeName="radius" values="0;1;0" dur="4.2s" repeatCount="indefinite"/>
    </feMorphology>
  </filter>
  <filter id='dilateFilter'>
    <feMorphology in="SourceGraphic" operator="dilate" radius="1" result="dilated">
        <animate attributeName="radius" values="1;8;1" dur="4.2s" repeatCount="indefinite"/>
    </feMorphology>
  </filter>  
  <filter id='blurFilter'>
    <feGaussianBlur in="SourceGraphic" stdDeviation="0.5" result="blur" />    
        <animate id='blurFilterAnimation' attributeName="stdDeviation" values="0;1;0" dur="0.42s" repeatCount="indefinite"/>
    </feGaussianBlur>
  </filter>
  <filter id='hueRotate'>
    <feColorMatrix in="SourceGraphic" type="hueRotate" values="180">
        <animate attributeName="values" values="0;360" dur="0.42s" repeatCount="indefinite"/>
    </feColorMatrix>
  </filter>
  </defs>
</svg>
'@


$audioPlayer = @"
<div class='audioPlayer'>
    <div class='playerProgress'>
        <audio controls="true" autoplay="true" id="audio">
            <!-- <source src='http://knhc-ice.streamguys1.com/live' type='audio/mpeg' /> -->
            <!-- <source src='https://kjzz.streamguys1.com/kbaq_mp3_128' type='audio/mpeg' /> -->
        </audio>
    </div>

    <div class='nowPlayingInput'>
        <input type="file" id="audioFile" multiple="true" />
    </div>
    <div id='currentlyPlaying'>
    </div>
</div>
"@

$html = @"
<style>
$style
</style>
$svgFilters
<div class='visualsGrid'>
    <canvas id='visuals'></canvas>
</div>
<div class='controlsGrid nowPlaying'>
    <!--
        <input id='audioUrl' type="url" id="audioUrl" />
        <label for='audioUrl'>Audio Url</label>
        <br />
    -->
    $audioPlayer    
</div>
<div class='overlay'>
    <details>
        <summary>View Source</summary>
        <div id='PowerShellCode'>
            <pre>
                <code class='language-PowerShell'>
$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))
                </code>
            </pre>
        </div>
    </details>
    <details>
        <summary>Options</summary>
        <div>
            <blockquote>
                <details>
                    <summary>Color</summary>
                    <fieldset class='colorFieldSet'>                        
                        
                        <legend>Colors</legend> 
                        <fieldset class='PaletteFieldSet'>
                            <legend>Palette</legend>
                            $(if ($site.Includes.SelectPalette) { . $site.Includes.SelectPalette })
                            <button id="SetRandomPalette" onclick="SetRandomPalette()">Random Palette</button>
                        </fieldset>                           
                        <fieldSet>                                                                                    
                            <legend>Primary</legend>
                            $(if ($site.includes.SelectColor) { . $site.Includes.SelectColor })
                            <button id="SetRandomColor" onclick="SetRandomColor()">Random Color</button>
                            <br/>
                            <input type="checkbox" id="autoColor" />
                            <label for="autoColor">Auto Color</label>
                            <br/>
                            <input type="checkbox" id="showCustomColor" />
                            <label for="showCustomColor">Custom Color</label>
                            <input type="color" id="customColor" />
                        </fieldset>
                        <fieldset>
                            <legend>Left</legend>                                
                            $(if ($site.includes.SelectColor) { . $site.Includes.SelectColor -id SelectLeftColor -Selected 'brightGreen' })
                        </fieldset>
                        <fieldset>
                            <legend>Right</legend>                                
                            $(if ($site.includes.SelectColor) { . $site.Includes.SelectColor -id SelectRightColor -Selected 'brightRed' })
                        </fieldset>
                    </fieldset>
                </details>
            </blockquote>
            <blockquote>
                <details>
                    <summary>Show</summary>                
                    <fieldset class='showFieldSet'>
                        <fieldset>
                            <input type="checkbox" id="showStereo" checked="true" />
                            <label for="showStereo">Stereo</label>
                        </fieldset>
                        <fieldset>
                            <input type="checkbox" id="showScope" checked="true" />
                            <label for="showScope">Scope</label>
                            <input type="checkbox" id="fillScope" />
                            <label for="fillScope">Fill</label>                                                        
                        </fieldset>
                        <fieldset>                            
                            <input type="checkbox" id="showRadialScope" checked="true" />
                            <label for="showRadialScope">Radial</label>
                            <input type="checkbox" id="fillRadialScope" />
                            <label for="fillRadialScope">Fill</label>
                        </fieldset>
                        <fieldset>
                            <div>
                                <input type="checkbox" id="showBars" checked="true" />
                                <label for="showBars">Bars</label>
                            </div>
                            <div>
                                <input type="checkbox" id="showPattern" checked="true" />
                                <label for="showPattern">Pattern</label>
                            </div>
                            <div>
                                <input type="checkbox" id="showVolumeCurve" checked="true" />
                                <label for="showVolumeCurve">Curve</label>
                            </div>
                        </fieldset>                        
                    </fieldset>
                </details>
            </blockquote>
            <blockquote>
                <details>
                    <summary>Audio</summary>
                    <div class='expandInline'>
                        <fieldset class='audioFieldSet'>                            
                            <fieldset class='levelsAndPanGrid'>                                
                                <input type='range' id='leftGain' min='0' max='100' value='50' class='verticalSlider' />
                                <label class='leftLabel' for="leftGain">L</label>                            
                                <input type='range' id='rightGain' min='0' max='100' value='50' class='verticalSlider' />
                                <label class='rightLabel' for="rightGain">R</label>
                                <input type='range' id='stereoPanner' min='-100' max='100' value='0' class='panInput' />
                                <label class='panLabel' for="stereoPanner">Pan</label>
                            </fieldset>                            
                            <fieldset class='rateAndPitch'>
                            <script>
                            function syncPlaybackRate(event) {
                                
                                document.getElementById('audio').playbackRate = event.target.value
                                document.getElementById('playbackRate').value = event.target.value
                                document.getElementById('playbackRateExact').value = event.target.value
                                event.preventDefault()
                            }                            
                            </script>
                            <div>
                                <label for="playbackRate">Playback Rate</label>                            
                                <input type='range' id='playbackRate' min='0.1' max='4' step='0.05' value='1' onchange='syncPlaybackRate(event)' />
                                <input type='number' id='playbackRateExact' max='8' step='0.01' value='1' maxlength='6' onchange='syncPlaybackRate(event)' />
                            </div>
                            <div>
                                <input type='checkbox' id='keepPitch' checked onchange="document.getElementById('audio').preservesPitch = event.target.checked"/>
                                <label for="keepPitch">Keep Pitch</label>
                            </div>
                            <div>
                                <!--
                                <script>
                                function syncNormalRate(event) {
                                    document.getElementById('audio').playbackRate = 1
                                    event.preventDefault()
                                }
                                </script>
                                <button id='normalRate' onClick="document.getElementById('audio').playbackRate = 1">Normal</button>
                                -->
                            </div>
                            
                            </fieldset>                        
                        </fieldset>                
                    </div>
                </details>
            </blockquote>
            <div>
                <button id="SavePNG" onclick="SavePNG('visuals')">Save PNG</button>
            </div>    
        
    </details>        
</div>

<script>
var audio = document.getElementById('audio');
var audioLoader = document.getElementById('audioFile');
var playlistFiles = []
var playlistIndex = 0;
const playlist = {
    index: 0,
    files: []
}

audioLoader.addEventListener('change', (e) => {
    var reader = new FileReader();    
    for (var i = e.target.files.length - 1 ; i >= 0; i--) {
        playlist.files.unshift(e.target.files[i])
    }
    playlist.index = 0
    reader.readAsDataURL(playlist.files[playlist.index])
    document.getElementById('currentlyPlaying').innerText = playlist.files[playlist.index].name
    reader.onload = (event) => { audio.src = event.target.result }
}, false);

audio.addEventListener('playing', (e) => {
    if (! audioSource) {
        ShowVisualizer();
    }    
    if (document.getElementById('playbackRate')) {
        audio.playbackRate = document.getElementById('playbackRate').value
    }
    if (document.getElementById('keepPitch')) {
        audio.preservePitch = document.getElementById('keepPitch').value
    }
}, false)

audio.addEventListener('ended', (e) => {
    if (playlist.index < (playlist.files.length - 1)) {        
        playlist.index++;
        var reader = new FileReader();
        reader.readAsDataURL(playlist.files[playlist.index])
        reader.onload = (event) => {
            audio.src = event.target.result;            
            audio.play();
            document.getElementById('currentlyPlaying').innerText = playlist.files[playlist.index].name
        }
    }
}, false)


// Get a canvas defined with ID "visuals"
const visualsCanvas = document.getElementById("visuals");
const visualsCanvas2d = visualsCanvas.getContext("2d");
const volumeHistory = [];
const translateDistance = {x:0.0, y:0.0, r: 0.0 };
const volumeCurves = []
let frameCount = 0
let audioSource = null

async function ShowVisualizer() {    
    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    const analyser = audioCtx.createAnalyser();
    analyser.fftSize = 2048;
    const barsAnalyser = audioCtx.createAnalyser();
    barsAnalyser.fftSize = 512;

    const bufferLength = analyser.frequencyBinCount;
    const barsBufferLength = barsAnalyser.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);
    const frequencyArray = new Uint8Array(barsBufferLength);

    const leftFrequencyAnalyser = audioCtx.createAnalyser()
    leftFrequencyAnalyser.fftSize = 2048;
    const leftDataArray = new Uint8Array(bufferLength);

    const rightFrequencyAnalyser = audioCtx.createAnalyser()
    rightFrequencyAnalyser.fftSize = 2048;    
    const rightDataArray = new Uint8Array(bufferLength);

    const leftBarsAnalyser = audioCtx.createAnalyser();    
    leftBarsAnalyser.fftSize = 512;
    const leftFrequencyArray = new Uint8Array(barsBufferLength);
    
    const rightBarsAnalyser = audioCtx.createAnalyser();    
    rightBarsAnalyser.fftSize = 512;
    const rightFrequencyArray = new Uint8Array(barsBufferLength);
    
    
    // For the color bar analyzer we want a average of a few frequencies    
    const colorSelector = document.getElementById('SelectColor')
    const leftColorSelector = document.getElementById('SelectLeftColor')
    const rightColorSelector = document.getElementById('SelectRightColor')
    const colorBarAnalyzer = audioCtx.createAnalyser();
    // so we want use a smaller fftSize
    colorBarAnalyzer.fftSize = 32;
    const colorArray = new Uint8Array(colorBarAnalyzer.frequencyBinCount);
    if (! audioSource) {
        audioSource = audioCtx.createMediaElementSource(document.getElementById("audio"));
    }    
    const splitter = audioCtx.createChannelSplitter(2);    
    const panner = audioCtx.createStereoPanner()
    const compressor = audioCtx.createDynamicsCompressor();
    const biquadFilter = audioCtx.createBiquadFilter()
    const merger = audioCtx.createChannelMerger(2);
    
    audioSource.connect(panner)
    panner.connect(splitter)

    // compressor.connect(splitter)
    // biquadFilter.connect(splitter)
    
    

    const leftGain = audioCtx.createGain();
    leftGain.gain.setValueAtTime(1, audioCtx.currentTime);
    splitter.connect(leftGain, 0);

    const rightGain = audioCtx.createGain()
    rightGain.gain.setValueAtTime(1, audioCtx.currentTime);
    splitter.connect(rightGain, 1)    

    // Connect the splitter back to the second input of the merger: we
    // effectively swap the channels, here, reversing the stereo image.
    // leftGain.connect(merger, 0, 1);
    leftGain.connect(leftFrequencyAnalyser)
    leftGain.connect(leftBarsAnalyser)
    leftGain.connect(merger, 0, 0);
    rightGain.connect(rightFrequencyAnalyser)
    rightGain.connect(rightBarsAnalyser)
    rightGain.connect(merger, 0, 1);        
    
    // Connect the source to be analysed
    audioSource.connect(analyser);
    audioSource.connect(barsAnalyser);

    merger.connect(audioCtx.destination);


    function measure(levelsArray, freqArray) {
        let totalVolume = 0.0
        let totalFrequency = 0.0
        let totalLow = 0.0
        let totalMid = 0.0
        let totalHigh = 0.0
        let totalNonZero = 0.0
        let lowCount = 1
        let midCount = 1
        let highCount = 1
        let nonZeroCount = 1
        
        const nonZero = []
        const levels = {
            all: [],
            low: [],
            mid: [],
            high: [],
            nonZero: []
        }
        
        const scopeLine = []
        for (let frequencyIndex = 0; frequencyIndex < levelsArray.length; frequencyIndex++) {            
            const frequencyValue = levelsArray[frequencyIndex];
            const frequencyRatio = frequencyValue/255.0                        
            let frequencyDelta = frequencyRatio            
            levels.all.push(frequencyRatio)            
            if (frequencyValue > 0 ) {
                
                levels.nonZero.push(frequencyRatio)
                totalNonZero += frequencyValue
                nonZeroCount++
            }
            totalVolume += frequencyValue;
            if (frequencyValue > 0 && frequencyIndex < (levelsArray.length / 3)) {                    
                // low frequencies                                
                levels.low.push(frequencyRatio)
                totalLow += frequencyValue;
                lowCount++
            } else if (frequencyValue > 0 && frequencyIndex < (2 * (levelsArray.length / 3))) {
                // mid frequencies                
                levels.mid.push(frequencyRatio)
                totalMid += frequencyValue;
                midCount++
            } else if (frequencyValue > 0) {
                // high frequencies                
                levels.high.push(frequencyRatio)
                totalHigh += frequencyValue;
                highCount++
            }    
        }
        
        const averageVolume = (totalVolume / levelsArray.length) / 255.0;
        const averageLow = (totalLow / lowCount) / 255.0;
        const averageMid = (totalMid / midCount) / 255.0;
        const averageHigh = (totalHigh / highCount)  / 255.0;
        const averageNonZero = (totalNonZero / nonZeroCount)  / 255.0;
        
        for (let sampleIndex = 0; sampleIndex < freqArray.length; sampleIndex++) {
            const sampleValue = freqArray[sampleIndex];
            scopeLine.push(sampleValue/128.0)
            totalFrequency += sampleValue;
        }

        const averageFrequency = (totalFrequency / freqArray.length) / 255.0;

        return {
            average: {
                volume: averageVolume,
                frequency: averageFrequency,
                low: averageLow,
                mid: averageMid,
                high: averageHigh,
                nonZero: averageNonZero
            },
            levels: levels,            
            scope: scopeLine
        }
    }


    // draw an oscilloscope of the current audio source
    function draw() {

        // First, request the next animation frame to call this
        requestAnimationFrame(draw);        

        // Then increment our frame count
        frameCount++

        // We want to optionally show or hide various parts of the visualization.
        // Lets gather this first, so we can avoid analyzing channels if we don't need them.
        const show  = {            
            bars: document.getElementById('showBars').checked,
            volumeCurve: document.getElementById('showVolumeCurve').checked,
            scope: document.getElementById('showScope').checked,
            stereo: document.getElementById('showStereo').checked,
            pattern: document.getElementById('showPattern').checked,
            radialScope: document.getElementById('showRadialScope').checked
        }

        const fill = {
            scope: document.getElementById('fillScope').checked,
            radialScope: document.getElementById('fillRadialScope').checked,
        }

        // Then, get our data from the Analyzers
        analyser.getByteTimeDomainData(dataArray);

        if (show.stereo) {
            leftFrequencyAnalyser.getByteTimeDomainData(leftDataArray)
            rightFrequencyAnalyser.getByteTimeDomainData(rightDataArray)
            barsAnalyser.getByteFrequencyData(frequencyArray);
            leftBarsAnalyser.getByteTimeDomainData(leftFrequencyArray)
            rightBarsAnalyser.getByteTimeDomainData(rightFrequencyArray)
        }
        
        // Adjust the panner
        let pannerValue = document.getElementById('stereoPanner').value
        if (pannerValue) { panner.pan.value = pannerValue / 100; }        

        // Set the channel gains
        let leftGainValue = document.getElementById('leftGain').value
        if (leftGainValue) { leftGain.gain.value = leftGainValue / 50 }            
        let rightGainValue = document.getElementById('rightGain').value
        if (rightGainValue) { rightGain.gain.value = rightGainValue / 50 }

        // And measure the audio
        const info = measure(frequencyArray, dataArray);
        let leftInfo = null
        let rightInfo = null
        let channelDelta = 0
        let measurements = []
        if (show.stereo) {
            leftInfo = measure(leftFrequencyArray, leftDataArray)     
            rightInfo = measure(rightFrequencyArray, rightDataArray)
            channelDelta = leftInfo.average.volume - rightInfo.average.volume
            measurements.push(rightInfo)
            measurements.push(leftInfo)
        }
        measurements.push(info)

        // Most of what we visualize is based off of levels.
        const levels = info.levels;
    
        let leftColor = getComputedStyle(visualsCanvas).getPropertyValue(leftColorSelector.value)
        if (! leftColor) { leftColor = 'green' }
        let rightColor = getComputedStyle(visualsCanvas).getPropertyValue(rightColorSelector.value)
        if (! rightColor) { rightColor = 'red' }

        // Get our turtle path and pattern
        let turtlePattern = document.getElementById("turtle-pattern")
        let turtlePath = document.getElementById("turtle-path")

        // If we are showing the path / pattern
        if (turtlePattern && show.pattern) {
            // Let us "wobble" a bit from our center based off of the average volume and frequency
            translateDistance.x = (info.average.volume * 23) + (info.average.frequency) * 42;
            translateDistance.y = (info.average.volume * 23) + (info.average.frequency - 0.5) * 42;
            // and slightly wobble in rotation
            translateDistance.r = ( (info.average.frequency - 0.5) * 180)
            // if things are not silent
            if (info.average.volume > 0) {
                // Then we want to transform the pattern based off of volume
                let scaleX = info.average.volume + (info.average.low*1.6)/(info.average.frequency)
                let scaleY = info.average.volume + (info.average.low*0.4+info.average.mid*0.8+info.average.high*1.5)/(info.average.frequency)
                turtlePattern.setAttribute("patternTransform", ``
                    translate(`${translateDistance.x} `${translateDistance.y})                    
                    scale(`${scaleX} `${scaleY}`)
                ``);
            }
            
            if (turtlePath) {
                turtlePath.setAttribute("opacity", (info.average.volume + info.average.low)/2);
            }
        } else if (turtlePattern && ! show.pattern) {
            let turtlePath = document.getElementById("turtle-path")
            if (turtlePath) {
                turtlePath.setAttribute("opacity", 0);
            }
        }

        // We want to change the rotation by setting its animation.
        // Why?  Because it ensures that it will not use the natural rotation animation
        // (this would rotation overload).
        let rotatePattern = document.getElementById("rotate-pattern")
        if (rotatePattern && show.pattern) {
            rotatePattern.setAttribute('values', (audio.currentTime/60 * 360 * 33) - (info.average.volume * 30) - translateDistance.r)
        }
       
        // Next up is creation of an automatic note color.
        // This area could use some improvement, which is why is not on by default.
        const notePercent = {}
        notePercent['red']   = info.average.low;
        notePercent['green'] = info.average.mid;
        notePercent['blue']  = info.average.high;
        const noteRGB = {}

        let baseColor = getComputedStyle(visualsCanvas).getPropertyValue(colorSelector.value);

        noteRGB['red'] = Math.floor(Math.min(info.average.volume + (info.average.low * 1.5) * 255, 255));
        noteRGB['green'] = Math.floor(Math.min(info.average.volume + (info.average.mid * 2.1) * 255, 255));
        noteRGB['blue'] = Math.floor(Math.min(info.average.volume + (info.average.high * 1.6) * 255, 255));
        noteRGB['color'] = ``#`${noteRGB.red.toString(16).padStart(2, '0')}`${noteRGB.green.toString(16).padStart(2, '0')}`${noteRGB.blue.toString(16).padStart(2, '0')}``;                    

        // getComputedStyle(document).setPropertyValue('--foreground',noteRGB['color'])

        // Ok, let us set up our foregroundColor 
        let foregroundColor = ''
        if (document.getElementById('autoColor').checked) {
            // If we wanted to use the auto color,
            // change it and the value
            foregroundColor = noteRGB['color']
            if (turtlePath) {
                // and change the foreground variable within the path.
                turtlePath.style.setProperty('--foreground', foregroundColor)
            }            
        }
        else if (document.getElementById('showCustomColor').checked) {
            // If we wanted to use a custom color, change values accordingly
            foregroundColor = document.getElementById('customColor').value            
            if (turtlePath) {                
                turtlePath.style.setProperty('--foreground', foregroundColor)
            }
        }
        else {
            // Otherwise, use the color CSS variable selected in the dropdown.
            foregroundColor = getComputedStyle(visualsCanvas).getPropertyValue(colorSelector.value)
            if (turtlePath) {
                turtlePath.style.setProperty('--foreground', foregroundColor)
            }
        }
       
        // Make our visuals take up the whole screen
        visualsCanvas.width = window.innerWidth
        visualsCanvas.height = window.innerHeight        
        visualsCanvas.style.width = "100%"
        visualsCanvas.style['margin-left'] = "0%"
        // And set our values accordingly.
        const visualsWidth = window.innerWidth
        const visualsHeight = window.innerHeight
    
        // One would think we would need to clear the rectangle, but one would be wrong.
        // One is not quite sure why this is the case.
        // visualsCanvas2d.clearRect(0, 0, visualsWidth, visualsHeight)

        // Our first set of lines are defined by the average bassline
        visualsCanvas2d.lineWidth = info.average.low * 4.2;        
        visualsCanvas2d.strokeStyle = foregroundColor;
        let x = 0;
        let scopes = []
        let nonZeros = [] 
        let channelNames = []       
        if (show.stereo) {
            channelNames.push("right")
            channelNames.push("left")
            scopes.push(rightInfo.scope)
            scopes.push(leftInfo.scope)
            nonZeros.push(rightInfo.levels.nonZero)
            nonZeros.push(leftInfo.levels.nonZero)
        }
        channelNames.push("all")
        scopes.push(info.scope)
        nonZeros.push(info.levels.nonZero)            
        
        // If we are showing a scopes,
        if (show.scope) {
            // let us draw each scope in a loop
            for (let scopeIndex =0; scopeIndex < scopes.length; scopeIndex++) {                
                const scope = scopes[scopeIndex]
                const nonZero = nonZeros[scopeIndex]
                // We are going to turn this into an SVG path
                const scopePath = []
                // This is actually pretty easy:
                // Our scope is a range of values between 0 and 2.
                // This makes most of the math easy.
                // For a standard ossciloscope, 
                // we start by dividing the screen into slices
                let sliceWidth = visualsWidth / scope.length;
                x = 0
                                
                // and go over each point in our scope
                for (let i = 0; i < scope.length; i++) {                    
                    // our 'vertical' value is translated into the range of `[1,-1]`
                    const v = scope[i] - 1;
                    // we want the scope to max out at 1/3 of the screen size
                    // so we weight our value by that number
                    let weight = (visualsHeight/3)
                    // We determine our point in the nonZero volume array
                    let nonZeroIndex = Math.floor(i/scope.length * nonZero.length)
                    // and multiply the weight
                    weight *= nonZero[nonZeroIndex]
                    // to calculate y, we take half of the height and add our weighted value.                
                    const y = (visualsHeight / 2) + v * weight
                    // we have to start the line at the first point
                    // every other point is a line segment.
                    if (i === 0) { scopePath.push(``M `${x} `${y}``)
                    } else { scopePath.push(``L `${x} `${y}``) }
                    // Increment our x and continue to the next point
                    x += sliceWidth;
                }

                // Congratulations, we now have a path of our first ossiloscope!            
                const scopePath2D = new Path2D(scopePath.join(' '))
                // just set the color
                // just set the color
                if (channelNames[scopeIndex] == "all") {
                    visualsCanvas2d.strokeStyle = foregroundColor
                    visualsCanvas2d.fillStyle = foregroundColor
                }
                if (channelNames[scopeIndex] == "right") {
                    visualsCanvas2d.strokeStyle = rightColor
                    visualsCanvas2d.fillStyle = rightColor
                }
                if (channelNames[scopeIndex] == "left") {
                    visualsCanvas2d.strokeStyle = leftColor
                    visualsCanvas2d.fillStyle = leftColor
                }
                                
                // and stroke or fill the path. 
                if (fill.scope) {
                    visualsCanvas2d.fill(scopePath2D)
                } else {
                    visualsCanvas2d.stroke(scopePath2D) 
                }
                
            }
        }

        if (show.radialScope) {
            for (let scopeIndex =0; scopeIndex < measurements.length; scopeIndex++) {                
                const scope = measurements[scopeIndex].scope
                
                // We are going to turn this into an SVG path
                const scopePath = []
                const centerX = visualsWidth / 2
                const centerY = visualsHeight / 2
                let volumeWeight = info.average.volume
                const radius = Math.min(centerX, centerY) * 0.66 * volumeWeight
                let angleStep = (Math.PI * 2) / scope.length                
                for (let i = 0; i < scope.length; i++) {
                    let angle = angleStep*i
                    if (i == (scope.length - 1)) {
                        scopePath.push('z')
                        continue
                    }
                    const v = scope[i]
                    const x = centerX + Math.cos(angleStep * i) * radius * v                    
                    const y = centerY + Math.sin(angleStep * i) * radius * v                    
                    if (angle === 0) {
                        scopePath.push(``M `${x} `${y}``)
                    } else {
                        scopePath.push(``L `${x} `${y}``)
                    }
                }
                                        
                // Congratulations, we now have a radial ossiloscope!
                const scopePath2D = new Path2D(scopePath.join(' '))
                // just set the color
                if (channelNames[scopeIndex] == "all") {
                    visualsCanvas2d.strokeStyle = foregroundColor
                    visualsCanvas2d.fillStyle = foregroundColor
                }
                if (channelNames[scopeIndex] == "right") {
                    visualsCanvas2d.strokeStyle = rightColor
                    visualsCanvas2d.fillStyle = rightColor
                }
                if (channelNames[scopeIndex] == "left") {
                    visualsCanvas2d.strokeStyle = leftColor
                    visualsCanvas2d.fillStyle = leftColor
                }
                                
                // and stroke the path. 
                if (fill.radialScope) {
                    visualsCanvas2d.fill(scopePath2D)
                } else {
                    visualsCanvas2d.stroke(scopePath2D) 
                }
            }
        }
                
        
        if (show.bars || show.volumeCurve) {
            x = 0;            
            const gapWidth = 3
            const barLevels = levels.nonZero
            let barWidth = ((visualsWidth * 1.0) / barLevels.length) - gapWidth
            let barHeight = 0;
            
            let path = []
            for (let i = 0; i < barLevels.length; i++) {
                barHeight = barLevels[i] * visualsHeight * 1/8;                
                let rectTop = visualsHeight - barHeight
                if (show.bars) {
                    visualsCanvas2d.fillStyle = foregroundColor;
                    visualsCanvas2d.fillRect(x, visualsHeight - barHeight, barWidth, barHeight);
                }                

                if (i == 0 ) {
                    path.push(``M `${x} `${rectTop - info.average.low * 4.2}``)
                } else {                    
                    path.push(``L `${x + (barWidth + gapWidth ) / 2} `${rectTop - info.average.low * 4.2}``)
                }
                x += barWidth + gapWidth;
            }                            

            if (show.volumeCurve) {
                let path2d = new Path2D(path.join(' '))
                //path.strokeWidth = 1
                visualsCanvas2d.strokeStyle = foregroundColor
                visualsCanvas2d.lineWidth = info.average.volume * 4.2;
                visualsCanvas2d.stroke(path2d)
            }            
        }
    }
    draw();
}
</script>
"@
$html

$OnResize