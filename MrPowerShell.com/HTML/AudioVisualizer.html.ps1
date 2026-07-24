#requires -Module Turtle 

if (-not $Page) {
    $Page = [Ordered]@{}
}

$title = "Audio Visualizer"

$description = "A simple audio visualizer using the Web Audio API, made with PowerShell."

if ($Page) {
    $page.Title = $title
    $Page.Description = $description
    $Page.Image = "https://MrPowerShell.com/HTML/AudioVisualizerInColor.png"
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
.invisible { display: none; }

.overlay { z-index: 50 }

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
    width: 29ch;
    grid-template-areas:
        'levelsAndPan'
        'rateAndPitch';
}

input[type="file"]::file-selector-button {
    text-align: center;
    color: var(--foreground);
    background-color: var(--background);
    border: thin solid var(--foreground);
    border-radius: 0.25rem;
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

.showFieldSet { width: 29ch }

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
    transform-style: preserve-3d;
}
    
#PowerShellCode {
    top: 100vh;
    width: 100vw;
}

pre { text-align: left }

.verticalSlider{ writing-mode: vertical-rl;direction: rtl }

// .colorWheel { filter: url('#colorWheel'); }
canvas { filter: url('#hueRotate'); }
#background-svg { filter: url('#hueRotate') }
.audioControls { text-align: center}

$(
foreach ($channel in '', '-left','-right') {
    foreach ($propertyName in 
        'lows', 'mids', 'highs',
        'volume', 'frequency',
        'delta'
    ) {
        if ($propertyName -eq 'delta' -and -not $channel) { continue }
@"
@property music$channel-$propertyName { syntax: '<number>'; inherits: true; initial-value: 0; }
"@
    }
}
)
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
        <animate attributeName="radius" values="0;1;0" dur="0.42s" repeatCount="indefinite"/>
      </feMorphology>
      <feMorphology operator="erode" radius="1" result="eroded">
        <animate attributeName="radius" values="1;4;1" dur="0.42s" repeatCount="indefinite"/>
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
  <filter id='tile' x="0" y="0" width="100%" height="100%">
    <feTile in="SourceGraphic" x="0" y="0" width="100%" height="100%" />
    <feTile />
  </fitler>
  <filter id="emboss">
      <feConvolveMatrix
        kernelMatrix="1 0 0
                      0 0 0
                      0 0 -1" />
  </filter>  
  <filter id='dilateFilter'>
    <feMorphology in="SourceGraphic" operator="dilate" radius="1" result="dilated">
        <!-- <animate attributeName="radius" values="1;2;1" dur="4.2s" repeatCount="indefinite"/> -->
    </feMorphology>
  </filter>  
  <filter id='blurFilter'>
    <feGaussianBlur in="SourceGraphic" stdDeviation="0.5" result="blur" />    
        <animate id='blurFilterAnimation' attributeName="stdDeviation" values="0;2;0" dur=".42s" repeatCount="indefinite"/>
    </feGaussianBlur>
  </filter>
  <filter id='hueRotate'>
    <feColorMatrix in="SourceGraphic" type="hueRotate" values="180">
        <animate attributeName="values" values="0;360" dur="4.2s" repeatCount="indefinite" id='hueRotateAnimation' />
    </feColorMatrix>    
  </filter>
  <filter id='saturate'>
    <feColorMatrix in="SourceGraphic" type="saturate" values="1">
        <!-- <animate attributeName="values" values="0;1;0" dur="4.2s" repeatCount="indefinite"/> -->
    </feColorMatrix>    
  </filter>
  </defs>
</svg>
'@


$audioPlayer = @"
<style>
.audio-player-grid {
    display:grid;
    grid-template-areas:
        ". . . controls . . ."                
        "time last play-pause progress mute-unmute next duration"
        ". . playlist playlist playlist . .";
    place-items: center;
    justify-items: center;
    grid-template-columns: auto auto auto 1fr auto auto auto;
    grid-template-rows: auto auto auto;
    gap: 1rem;
}
#audio-player-progress {
    grid-area: progress;
    place-items: center;
    width: 100%;
}
#audio-player-range {
    grid-area: progress;
    place-items: center;
    opacity: 0.5;
    width: 100%;
}
#lastTrack {
    grid-area: last;
    place-items: center;
}
#nextTrack {
    grid-area: next;
    place-items: center;
}
#audioFile {
    grid-area: file;
}
#audio-player-time {
    grid-area: time;
}
#audio-player-duration {
    grid-area: duration;
}
.playlist {
    grid-area: playlist;
    place-items: center;
    display: flex;
    flex-direction: row;
    box-sizing: border-box;
    line-height: 2rem;
    gap: 1rem;
}
.audio-controls {
    grid-area: controls;
}

.play-pause {
    grid-area: play-pause;    
}
.mute-unmute {
    grid-area: mute-unmute;    
}
#audioFile {
    display: none;
}
</style>

<div class='audio-player-grid'>
    <div class='audio-controls'>        
        <label for='audioFile'>Select File</label>
        <input type="file" id="audioFile" multiple="true" />    
    </div>
    

    <span id='audio-player-time'></span>

    <progress id='audio-player-progress' min='0' max='100'></progress>
    
    <input type='range' id='audio-player-range' max='100' min='0' step='1' onchange='
        document.getElementById("audio").currentTime =
            document.getElementById("audio").duration/100 * event.target.value
    '></input>
    <span id='audio-player-duration'></span>

    <section class='play-pause'>
        <button id='playButton' class='invisible'>$(. $site.includes.Feather 'play')</button>
        <button id='pauseButton' class='invisible'>$(. $site.includes.Feather 'pause')</button>
    </section>

    <section class='mute-unmute'>
        <button id='volume-unmute' class='invisible'>$(. $site.includes.Feather 'volume-2')</button>
        <button id='volume-mute' class='invisible'>$(. $site.includes.Feather 'volume-x')</button>
    </section>
    

    <button id='lastTrack'>$(. $site.includes.Feather 'skip-back')</button>
    <button id='nextTrack'>$(. $site.includes.Feather 'skip-forward')</button>
    <div class='playlist'>
        <label for='select-playlist'>Playlist</label>
        <select id='select-playlist'>        
        </select>
        <button id='removeTrack' class='invisible'>$(. $site.includes.Feather 'file-minus')</button>
    </div>
    <audio autoplay="true" id="audio"></audio>
</div>

<script type='module'>
    const searchParameters = new URLSearchParams(window.location.search)
    const queryAliases = {
        "Source": ["Source", "source", "Src", "src", "S", "s"]
    }
    const queryParameters = {}
    for (const key of Object.keys(queryAliases)) {            
        for (const p of queryAliases[key]) {
            if (searchParameters.has(p)) {
                queryParameters[key] = searchParameters.get(p)
                break
            }
        }
    }
    if (queryParameters.Source) {
        try {
            var preFetch = await fetch(queryParameters.Source).then(r => r.blob())
            document.getElementById('audio').src = queryParameters.Source
        } catch {
            console.log('no go')
        }
        
    }
</script>

<div id='currentlyPlaying'>
    <span id='currentTrackName'>
    </span>
</div>
"@

$numberProperties = @()
$colorProperties = @()
$checkedProperties = @()

filter toCssVariable {
    ($_ -replace '^-{0,}', '--' -creplace '(?<=\p{Ll})\s{0,}(?=\p{Lu})', '-').ToLower()
}

filter checkbox {
    $in = $_
    $inVar = $in | toCssVariable
    if ($args -match 'checked') {
        $checkedProperties += $inVar
    } else {
        $numberProperties += $inVar
    }
    
    $inId = $inVar -replace '^--' -replace '-{1,}', '-'   

    @(
        "<section>"
        "<label for='$inId'>$([Web.HttpUtility]::HtmlEncode($in))</label>"
        "<input type='checkbox' id='$inId'$(
            if ($args -match 'checked') { ' checked'}
        )></input>"
        "</section>"
    ) -join [Environment]::NewLine
    
    
}

filter slider {
    $in = $_
    $inVar = $in | toCssVariable
    $numberProperties += $inVar
    $inId = $inVar -replace '^--' -replace '-{1,}', '-'
    @("<section>"
    "<label for='$inId'>$([Web.HttpUtility]::HtmlEncode($in))</label>"
    "<input type='range' id='$inId'$(
        if ($args) {
            ' ' + ($args -join ' ')
        }
    )></input>"
    "</section>") -join [Environment]::NewLine
}

filter verticalSlider {
    $in = $_
    $inVar = $in | toCssVariable
    $numberProperties += $inVar
    $inId = $inVar -replace '^--' -replace '-{1,}', '-'
    "<input type='range' id='$inId'$(
        if ($args) {
            ' ' + ($args -join ' ')
        }
    )></input>"
    "<label for='$inId'>$([Web.HttpUtility]::HtmlEncode($in))</label>"
}

filter colorPicker {
    $in = $_
    $inVar = $in | toCssVariable
    $colorProperties += $inVar
    $inId = $inVar -replace '^--' -replace '-{1,}', '-'
    "<input type='color' id='$inId'$(
        if ($args) {
            ' ' + ($args -join ' ')
        }
    ) onchange='document.body.style.setProperty(`"$inVar`", event.target.value)'></input>"
    "<label for='$inId'>$([Web.HttpUtility]::HtmlEncode($in))</label>"
}


$options = [Ordered]@{
    Audio = @"
<style>
.pan-and-gain {
    display: grid;    
    place-items: center; 
    grid-template-areas: 
        'leftGain pan rightGain' 'leftGain rate rightGain';
    gap: 1rem;    
    grid-template-colums: auto max-content auto;
}
.rateAndPitch {
    grid-area: rate;
    display: flex;
    flex-direction: column;
    text-align: center;
}
.pan {
    text-align: center;
    place-items: center;
    display: flex;
    flex-direction: column;
    grid-area: pan;
}
.pan input[type='range'] {
    width: 100%;
}
.pan section {
    width: 100%;
}
.leftGain {
    grid-area: leftGain;
    display:flex;
    flex-direction: column;
    place-items: center;
}
.rightGain {
    grid-area: rightGain;
    display:flex;
    flex-direction: column;
    place-items: center;
}
.panInput {width: 100%; }
</style>

<fieldset class='pan-and-gain'>    
    <section class='leftGain'>
        $('Left Gain' | . verticalSlider "min='0' max='100' value='50' class='verticalSlider'")
    </section>
    <section class='pan'> 
$(
    'Stereo Pan' | . slider "min='-100' max='100' value='0' class='panInput'"
)
        <section class='panButtons'>
            <button onclick='
                document.getElementById("stereo-pan").value = -100
                document.body.style.setProperty("--stereo-pan", -100)
            '>Left</button>
            <button onclick='
                document.getElementById("stereo-pan").value = 0
                document.body.style.setProperty("--stereo-pan", 0)
            '>Center</button>
            <button onclick='
                document.getElementById("stereo-pan").value = 100
                document.body.style.setProperty("--stereo-pan", 100)
            '>Right</button>
        </section>
    </section>
    <section class='rightGain'>
        $('Right Gain' | . verticalSlider "min='0' max='100' value='50' class='verticalSlider'")
    </section>    
    <fieldset class='rateAndPitch'>
        <legend>Rate</legend>
        <script>
        function syncPlaybackRate(event) {        
            document.getElementById('audio').playbackRate = event.target.value
            document.getElementById('playbackRate').value = event.target.value
            document.getElementById('playbackRateExact').value = event.target.value
            event.preventDefault()
        }                            
        </script>
        
        <label for="playbackRate">Playback Rate</label>                            
        <input type='number' id='playbackRateExact' max='8' step='0.005' value='1' maxlength='6' onchange='syncPlaybackRate(event)' />
        <input type='range' id='playbackRate' min='0.1' max='4' step='0.005' value='1' onchange='syncPlaybackRate(event)' />        
        <input type='checkbox' id='keepPitch' checked onchange="document.getElementById('audio').preservesPitch = event.target.checked"/>
        <label for="keepPitch">Keep Pitch</label>
    </fieldset>
    
</fieldset>

"@    
    Visuals = @"
    <style>
    .show-fill-scopes {
        display: grid;
        grid-template-columns: repeat(10, 1fr);
        grid-template-rows: auto auto;
        place-items: center;
        gap: 1rem;
    }

    .channel-scopes {
        display:grid;
        grid-template-columns: repeat(3, 1fr);
        place-items: center;
        gap: 1rem;
    }
    
    .left-scopes {
        display:grid;
        grid-template-columns: 1;
        grid-template-rows: repeat(auto);
        place-items: center;
        gap: 1rem;
    }
    .mono-scopes {
        display:grid;
        grid-template-columns: 1;
        grid-template-rows: repeat(auto);
        place-items: center;
        gap: 1rem;
    }
    .right-scopes {
        display:grid;
        grid-template-columns: 1;
        grid-template-rows: repeat(auto);
        place-items: center;
        gap: 1rem;
    }

    </style>
    <fieldset class='PaletteFieldSet'>
        <legend>Palette</legend>                                
        $(if ($site.Includes.SelectPalette) { . $site.Includes.SelectPalette })
        <button id="SetRandomPalette" onclick="SetRandomPalette()">Random Palette</button>
        <input type="checkbox" id="HueRotateSwitch" />
        <label for="HueRotateSwitch">HueRotate</label>
        <input type="number" id="HueRotateMultiplier" value="720" />
        <label for="HueRotateSwitch">x</label>
    </fieldset>    
    <fieldset class='channel-scopes'>
        <legend>Scopes</legend>
        <section class='left-scopes'>
        $(
            'Show Left Scope' | . checkbox checked
            'Fill Left Scope' | . checkbox  
            $(if ($site.includes.SelectColor) {
                . $site.Includes.SelectColor -id SelectLeftColor -Selected 'brightGreen'
            })
            'Show Left Radial' | . checkbox checked
            'Fill Left Radial' | . checkbox            
            'Left Radial Frequency' | 
                slider "min='1' max='8' value='2'"
            'Left Radial Amplitude' | 
                slider "min='0' max='100' value='50'"
        )
        </section>
        <section class='mono-scopes'>
        $(
            'Show Mono Scope' | . checkbox checked
            'Fill Mono Scope' | . checkbox
            $(if ($site.includes.SelectColor) { . $site.Includes.SelectColor -Selected 'cyan' })
            'Show Radial Scope' | . checkbox checked
            'Fill Radial Scope' | . checkbox
            'Radial Frequency' | 
                slider "min='1' max='8' value='2'"
            'Radial Amplitude' | 
                slider "min='0' max='100' value='75'"
        )
        </section>
        <section class='right-scopes'>
        $(
            'Show Right Scope' | . checkbox checked
            'Fill Right Scope' | . checkbox
            $(if ($site.includes.SelectColor) {
                . $site.includes.SelectColor -id SelectRightColor -Selected 'brightRed'
            })            
            'Show Right Radial' | . checkbox checked
            'Fill Right Radial' | . checkbox
            'Right Radial Frequency' | 
                slider "min='1' max='8' value='2'"
            'Right Radial Amplitude' | 
                slider "min='0' max='100' value='25'"
        )
        </section>
    </fieldset>
    <fieldset>
        <legend>Pattern</legend>
        
        <label for="showPattern">Show Pattern</label>
        <input type="checkbox" id="showPattern" checked="true" />        
        
        <label for="fillPattern">Fill Pattern </label>
        <input type="checkbox" id="fillPattern" />
        
        <label for="evenOddPattern">Even/Odd Fill</label>
        <input type="checkbox" id="evenOddPattern" checked />
        
        
        <label for="SelectPatternColor">Pattern Color</label>
        $(if ($site.includes.SelectColor) {
            . $site.includes.SelectColor -id SelectPatternColor -Selected 'purple'
        })
    </fieldset>
    <fieldset>
        <legend>Bars</legend>
        <div>
            <input type="checkbox" id="showBars" checked="true" />
            <label for="showBars">Bars</label>
            $(if ($site.includes.SelectColor) {
                . $site.includes.SelectColor -id SelectBarsColor -Selected 'brightCyan'
            })
        </div>                            
        <div>
            <input type="checkbox" id="showVolumeCurve" checked="true" />
            <label for="showVolumeCurve">Curve</label>
            $(if ($site.includes.SelectColor) {
                . $site.includes.SelectColor -id SelectCurveColor -Selected 'brightYellow'
            })
        </div>
    </fieldset>
    <fieldset>
        <legend>CSS</legend>
        <div>
            <label for="transformFunction">transform</label>
            <input id="transform-function" onchange="document.getElementById('visuals').style.transform = event.target.value"></input>
        </div>
        <div>        
            <label for="background-blend-mode">background-blend-mode</label>
            <select id='background-blend-mode' onchange="document.body.style['background-blend-mode'] = event.target.value">
                <option selected>normal</option>
                <option>darken</option>
                <option>multiply</option>
                <option>color-burn</option>
                <option>lighten</option>
                <option>screen</option>
                <option>color-dodge</option>
                <option>overlay</option>
                <option>soft-light</option>
                <option>hard-light</option>
                <option>difference</option>
                <option>exclusion</option>  
                <option>hueoption>
                <option>saturation</option>
                <option>color</option>
                <option>luminosity</option>
            </select>
        </div>
        <div>
            <label for="mix-blend-mode">mix-blend-mode</label>
            <select id='mix-blend-mode' onchange="document.body.style['mix-blend-mode'] = event.target.value">
                <option>normal</option>
                <option>darken</option>
                <option>multiply</option>
                <option>color-burn</option>
                <option>lighten</option>
                <option>screen</option>
                <option>color-dodge</option>
                <option>overlay</option>
                <option>soft-light</option>
                <option>hard-light</option>
                <option>difference</option>
                <option selected>exclusion</option>  
                <option>hueoption>
                <option>saturation</option>
                <option>color</option>
                <option>luminosity</option>
            </select>
        </div>        
    </fieldset>
"@                                
    "View Source" = @"
<div id='PowerShellCode'>
    <pre>
        <code class='language-PowerShell'>
$([Web.HttpUtility]::HtmlEncode($MyInvocation.MyCommand.ScriptBlock))
        </code>
    </pre>
</div>
"@
    
}

$options = [Ordered]@{Options=$options}



filter toTree {
    $in = $_
    $mySelf = $MyInvocation.MyCommand        
    $arguments = @($args)
    if ($in -is [Collections.IDictionary]) {
        # "<ul class='directory'>"
        $in.GetEnumerator() | . $mySelf @arguments
        # "</ul>"        
    } elseif ($in.Key -is [string]) {
        $newArgs = @($arguments) + $in.Key
        "<details class='$($newArgs -join '-')'>"
            "<summary>$([Web.HttpUtility]::HtmlEncode($in.Key))</summary>"
            "<ul>"
            if ($in.Value -is  [Collections.IDictionary]) {                
                $in.Value | . $mySelf @newArgs
            } else {
                $in.Value
            }
            "</ul>"
        "</details>"
    }
}

$cssProperties = @(
foreach ($checkedProperty in $checkedProperties) {
    "@property $checkedProperty { syntax: '<number>'; inherits: true; initial-value:1}"
}

foreach ($numberProperty in $numberProperties) {
    "@property $numberProperty { syntax: '<number>'; inherits: true; initial-value:0;}"
}

foreach ($colorProperty in $colorProperties) {
    "@property $colorProperty { syntax: '<color>'; inherits: true; initial-value:transparent;}"
}
)


$html = @"
<style>
$(
$cssProperties -join [Environment]::NewLine
)
$style
</style>
$svgFilters
<div class='visualsGrid'>
    <canvas id='visuals'></canvas>
</div>
<div class='overlay'>
    $audioPlayer
    $($options | toTree)    
</div>

<script>

var audio = document.getElementById('audio')
var audioLoader = document.getElementById('audioFile')
var nextTrack = document.getElementById('nextTrack')
var lastTrack = document.getElementById('lastTrack')
var playButton = document.getElementById('playButton')
var pauseButton = document.getElementById('pauseButton')
var unmuteButton = document.getElementById('volume-unmute')
var muteButton = document.getElementById('volume-mute')
var removeTrack = document.getElementById('removeTrack')
const selectPlaylist = document.getElementById('select-playlist')
var playlistFiles = []
var playlistIndex = 0;

const playlist = {
    index: 0,
    files: [],
    cache: {},
    RemoveTrack: async function() {
        if (! playlist.files.length) { return }
        playlist.files.splice(playlist.index, 1)
        selectPlaylist.remove(playlist.index)
        if (! playlist.files.length) {
            removeTrack.classList.add('invisible')
            audio.src = null;
        } else {
            playlist.NowPlaying()
        }
    },    
    NextTrack: async function() {
        if (! playlist.files.length) { return }
        playlist.index++
        if (playlist.index > playlist.files.length) {
            playlist.index = 0
        }        
        playlist.NowPlaying()
    },
    LastTrack: async function() {
        if (! playlist.files.length) { return }
        playlist.index--
        if (playlist.index < 0) {
            playlist.index = playlist.files.length - 1
        }
        playlist.NowPlaying()
    },
    Import: async function(e) {
        for (var i = e.target.files.length - 1 ; i >= 0; i--) {
            playlist.files.unshift(e.target.files[i])
            const newOption = document.createElement("option")
            newOption.value = e.target.files[i].name
            newOption.text = e.target.files[i].name
            selectPlaylist.add(newOption, 0)
        }            
        playlist.index = 0        
        playlist.NowPlaying();

    },
    NowPlaying: async function() {
        var fileToPlay = playlist.files[playlist.index]
        if (! fileToPlay) { return }
        if (! playlist.cache[fileToPlay.name]) {
            var reader = new FileReader()
            reader.readAsDataURL(fileToPlay)
            reader.onload = async (event) => { 
                playlist.cache[fileToPlay.name] = event.target.result
                audio.src = event.target.result
                // document.getElementById('currentTrackName').innerText = fileToPlay.name
            }        
        } else {
            audio.src = playlist.cache[fileToPlay.name]
            // document.getElementById('currentTrackName').innerText = fileToPlay.name            
        }
            
        
        if (playlist.files.length > (playlist.index + 1)) {
            var reader = new FileReader()
            var nextIndex = playlist.index + 1
            var nextFile = playlist.files[nextIndex]
            reader.readAsDataURL(nextFile)
            reader.onload = async (event) => { 
                playlist.cache[nextFile.name] = event.target.result
            }
        }

        selectPlaylist.selectedIndex = playlist.index; 
    }
}

nextTrack.addEventListener('click', (e) => { playlist.NextTrack() })
lastTrack.addEventListener('click', (e) => { playlist.LastTrack() })

playButton.addEventListener('click', (e) => {     
    audio.play()
})    

pauseButton.addEventListener('click', (e) => {     
    audio.pause()
})

muteButton.addEventListener('click', (e) => { 
    muteButton.classList.add('invisible')
    unmuteButton.classList.remove('invisible')        
    audio.muted = true
})

unmuteButton.addEventListener('click', (e) => { 
    unmuteButton.classList.add('invisible')
    muteButton.classList.remove('invisible')    
    audio.muted = false
})

removeTrack.addEventListener('click', (e) => {
    playlist.RemoveTrack()
})

const readers = []

audioLoader.addEventListener('change', playlist.Import, false);

audio.addEventListener('playing', (e) => {
    if (! audioSource) {
        ShowVisualizer();
    }
    playButton.classList.add('invisible')
    pauseButton.classList.remove('invisible')
    if (audio.muted) {
        muteButton.classList.add('invisible')
        unmuteButton.classList.remove('invisible')
    } else {
        unmuteButton.classList.add('invisible')
        muteButton.classList.remove('invisible')        
    }
        
    removeTrack.classList.remove('invisible')
        
    if (document.getElementById('playbackRate')) {
        audio.playbackRate = document.getElementById('playbackRate').value
    }
    if (document.getElementById('keepPitch')) {
        audio.preservePitch = document.getElementById('keepPitch').value
    }
}, false)

audio.addEventListener('pause', (e)=> {
    playButton.classList.remove('invisible')
    pauseButton.classList.add('invisible')
})

audio.addEventListener('ended', (e) => {
    if (playlist.index < (playlist.files.length - 1)) {        
        playlist.index++;
        playlist.NowPlaying()        
    }
}, false)

selectPlaylist.addEventListener('change', (e) => {
    playlist.index = e.target.selectedIndex
    playlist.NowPlaying();
})


// Get a canvas defined with ID "visuals"
const visualsCanvas = document.getElementById("visuals");
const visualsCanvas2d = visualsCanvas.getContext("2d");
const volumeHistory = [];
const translateDistance = {x:0.0, y:0.0, r: 0.0 };
const volumeCurves = []
let frameCount = 0
let audioSource = null

function isChecked(...ids) {
    for (const id of ids) {        
        if (document.getElementById(id)?.checked) { return true }
    }
    return false    
}


function valueOf(...ids) {        
    for (const id of ids) {
        const element = document.getElementById(id)
        if (element?.value) { return element.value}
    }
    return null    
}

function valuesOf(...ids) {
    const output = {}
    for (const id of ids) {
        output[id] = document.getElementById(id)?.value
    }
    return output
}

function propertyValueOf(propertyName) {
    getComputedStyle(visualsCanvas).getPropertyValue(propertyName)
}


async function ShowVisualizer() {    
    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    if (! audioSource) {    
        audioSource = audioCtx.createMediaElementSource(document.getElementById("audio"));
    }
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

    const framesPerSecond = {
        count: 0,
        start: new Date()
    };
    
    
    // For the color bar analyzer we want a average of a few frequencies    
    const colorSelector = document.getElementById('SelectColor')
    const leftColorSelector = document.getElementById('SelectLeftColor')
    const rightColorSelector = document.getElementById('SelectRightColor')
    const colorBarAnalyzer = audioCtx.createAnalyser();
    // so we want use a smaller fftSize
    colorBarAnalyzer.fftSize = 32;
    const colorArray = new Uint8Array(colorBarAnalyzer.frequencyBinCount);        
    const splitter = audioCtx.createChannelSplitter(2);    
    const panner = audioCtx.createStereoPanner()        
    const merger = audioCtx.createChannelMerger(2);
    
    audioSource.connect(panner)
    panner.connect(splitter)

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

        framesPerSecond.count++

        const audioPlayerElement = document.getElementById('audio');
        const audioPlayerProgress = document.getElementById('audio-player-progress');
        const audioPlayerTime = document.getElementById('audio-player-time')
        const audioPlayerDuration = document.getElementById('audio-player-duration')

        if (audioPlayerElement.duration && ! (
            framesPerSecond.count % 11
        )) {
            audioPlayerProgress.value = 
                (audioPlayerElement.currentTime / audioPlayerElement.duration) * 100
            
            audioPlayerTime.innerText =
                Math.floor(audioPlayerElement.currentTime / 60).toString().padStart(2, '0') + ":" +
                    Math.round(audioPlayerElement.currentTime % 60).toString().padStart(2, '0')
            audioPlayerDuration.innerText =
                Math.floor(audioPlayerElement.duration / 60).toString().padStart(2, '0') + ":" + 
                    Math.round(audioPlayerElement.duration % 60).toString().padStart(2, '0')
        }

        // Then increment our frame count
        frameCount++

        const optionNames = ['Bars','Left','Pattern','RadialScope','Right','Scope','Stereo','VolumeCurve']
        const options = {}
        for (const groupName of ['show','fill','evenOdd']) {
            options[groupName] = {}
            for (const optionName of optionNames) {
                options[groupName][optionName.substring(0,1).toLowerCase() + optionName.substring(1)] = isChecked(groupName + optionName)
            }
        }        
        const show = options.show
        const fill = options.fill
        const evenOdd = options.evenOdd
        const style = document.body.style

        const colors = {
            bars: getComputedStyle(visualsCanvas).getPropertyValue(
                valueOf('SelectBarsColor')
            ),                                
            left: getComputedStyle(visualsCanvas).getPropertyValue(
                valueOf('SelectLeftColor')
            ),
            right: getComputedStyle(visualsCanvas).getPropertyValue(
                valueOf('SelectRightColor')
            ),
            scope: getComputedStyle(visualsCanvas).getPropertyValue(
                valueOf('SelectScopeColor')
            ),
            pattern: getComputedStyle(visualsCanvas).getPropertyValue(
                valueOf('SelectPatternColor')
            ),
            radial: getComputedStyle(visualsCanvas).getPropertyValue(
                valueOf('SelectRadialColor')
            ),            
            curve: getComputedStyle(visualsCanvas).getPropertyValue(
                valueOf('SelectCurveColor')
            )
        }

        // Then, get our data from the Analyzers
        analyser.getByteTimeDomainData(dataArray);

        
        leftFrequencyAnalyser.getByteTimeDomainData(leftDataArray)
        rightFrequencyAnalyser.getByteTimeDomainData(rightDataArray)
        barsAnalyser.getByteFrequencyData(frequencyArray);
        leftBarsAnalyser.getByteTimeDomainData(leftFrequencyArray)
        rightBarsAnalyser.getByteTimeDomainData(rightFrequencyArray)
    
        
        // Adjust the panner
        let pannerValue = document.body.style.getPropertyValue('--stereo-pan')
        if (pannerValue) { panner.pan.value = pannerValue / 100; }        

        // Set the channel gains
        let leftGainValue = document.body.style.getPropertyValue('--left-gain')
        if (leftGainValue) { leftGain.gain.value = leftGainValue / 50 }            
        let rightGainValue = document.body.style.getPropertyValue('--right-gain')
        if (rightGainValue) { rightGain.gain.value = rightGainValue / 50 }
        
        // And measure the audio
        const info = measure(frequencyArray, dataArray);    

        let leftInfo = null
        let rightInfo = null
        let channelDelta = 0
        let measurements = []

        const computedStyle = document.body.style
        if (computedStyle) {
            computedStyle.setProperty('--volume',info.average.volume)
            computedStyle.setProperty('--frequency',info.average.frequency)
            computedStyle.setProperty('--music-lows',info.average.low)
            computedStyle.setProperty('--music-mids',info.average.middle)
            computedStyle.setProperty('--music-highs',info.average.high)
        }
                
        
        leftInfo = measure(leftFrequencyArray, leftDataArray)     
        rightInfo = measure(rightFrequencyArray, rightDataArray)
        channelDelta = leftInfo.average.volume - rightInfo.average.volume
        measurements.push(rightInfo)
        measurements.push(leftInfo)
        if (computedStyle) {
            computedStyle.setProperty('--music-left-volume',leftInfo.average.volume)
            computedStyle.setProperty('--music-left-frequency',leftInfo.average.frequency)
            computedStyle.setProperty('--music-left-lows',leftInfo.average.low)
            computedStyle.setProperty('--music-left-mids',leftInfo.average.middle)
            computedStyle.setProperty('--music-left-highs',leftInfo.average.high)
            computedStyle.setProperty('--music-right-volume',rightInfo.average.volume)
            computedStyle.setProperty('--rightFrequency',rightInfo.average.frequency)
            computedStyle.setProperty('--music-right-lows',rightInfo.average.low)
            computedStyle.setProperty('--music-right-mids',rightInfo.average.middle)
            computedStyle.setProperty('--music-right-highs',rightInfo.average.high)

            computedStyle.setProperty('--music-left-delta',
                leftInfo.average.volume - rightInfo.average.volume
            )
            computedStyle.setProperty('--music-right-delta',
                rightInfo.average.volume - leftInfo.average.volume
            )
        }
    
        measurements.push(info)
        // Most of what we visualize is based off of levels.
        const levels = info.levels;
        let saturateFilter = document.getElementById('saturate')
        // saturateFilter.setAttribute('values', (info.average.low + info.average.high) * 1.25)

        let hueRotateFilter = document.getElementById('hueRotateAnimation')
        if (hueRotateFilter) {
            if (document.getElementById('HueRotateSwitch')?.checked) {
                let hueRotateMultiplier = document.getElementById('HueRotateMultiplier')?.value 
                if (! hueRotateMultiplier) { hueRotateMultiplier = 720 }
                hueRotateFilter.setAttribute('values', 
                    ((info.average.volume + info.average.frequency) * hueRotateMultiplier)
                )
            } else {
                hueRotateFilter.setAttribute('values', 0)
            }
        }        

        let patternColor = getComputedStyle(visualsCanvas).getPropertyValue(leftColorSelector.value)
    
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
                turtlePath.style.setProperty('--foreground', colors.pattern)
                if (fill.pattern) {
                    turtlePath.setAttribute("fill", colors.pattern)
                    if (evenOdd.pattern) {
                        turtlePath.setAttribute("fill-rule", "evenodd")    
                    } else {
                        turtlePath.setAttribute("fill-rule", "nonzero")
                    }                    
                    turtlePath.setAttribute("stroke", "transparent")
                } else {
                    turtlePath.setAttribute("stroke", colors.pattern)
                    turtlePath.setAttribute("fill", "transparent")
                }
                
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
        if (document.getElementById('autoColor')?.checked) {
            // If we wanted to use the auto color,
            // change it and the value
            foregroundColor = noteRGB['color']
            if (turtlePath) {
                // and change the foreground variable within the path.
                turtlePath.style.setProperty('--foreground', foregroundColor)
            }            
        }
        else if (document.getElementById('showCustomColor')?.checked) {
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
                turtlePath.style.setProperty('--foreground', colors.pattern)
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
    
        channelNames.push("right")
        channelNames.push("left")
        scopes.push(rightInfo.scope)
        scopes.push(leftInfo.scope)
        nonZeros.push(rightInfo.levels.nonZero)
        nonZeros.push(leftInfo.levels.nonZero)
    
        channelNames.push("mono")
        scopes.push(info.scope)
        nonZeros.push(info.levels.nonZero)            
        
        // If we are showing a scopes,
        
        // let us draw each scope in a loop
        nextScope: for (let scopeIndex =0; scopeIndex < scopes.length; scopeIndex++) {                
            const scope = scopes[scopeIndex]
            const nonZero = nonZeros[scopeIndex]
            let fillScope = false;
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
            if (channelNames[scopeIndex] == "mono") {
                visualsCanvas2d.strokeStyle = foregroundColor
                visualsCanvas2d.fillStyle = foregroundColor
                if (style.getPropertyValue('--show-mono-scope') <= 0 ) continue nextScope                
                if (style.getPropertyValue('--fill-mono-scope') > 0) {
                    visualsCanvas2d.fill(scopePath2D)
                }
                visualsCanvas2d.stroke(scopePath2D)
            }
            if (channelNames[scopeIndex] == "right") {
                visualsCanvas2d.strokeStyle = rightColor
                visualsCanvas2d.fillStyle = rightColor
                if (style.getPropertyValue('--show-right-scope') <= 0 ) continue nextScope
                
                if (style.getPropertyValue('--fill-right-scope') > 0) {
                    visualsCanvas2d.fill(scopePath2D)
                }
                visualsCanvas2d.stroke(scopePath2D)
            }
            if (channelNames[scopeIndex] == "left") {
                visualsCanvas2d.strokeStyle = leftColor
                visualsCanvas2d.fillStyle = leftColor
                if (style.getPropertyValue('--show-left-scope') <= 0 ) continue nextScope
                if (style.getPropertyValue('--fill-left-scope') > 0) {
                    visualsCanvas2d.fill(scopePath2D)
                }
                visualsCanvas2d.stroke(scopePath2D)
            }                            
        }        
        
        
        let radialFrequency = 0
        let radialAmplitude = 0
        nextScope: for (let scopeIndex =0; scopeIndex < measurements.length; scopeIndex++) {                
            const scope = measurements[scopeIndex].scope            

            if (channelNames[scopeIndex] == "right") {
                radialFrequency = style.getPropertyValue('--right-radial-frequency')
                radialAmplitude = style.getPropertyValue('--right-radial-amplitude')
            } else if (channelNames[scopeIndex] == "left") {              
                radialFrequency = style.getPropertyValue('--left-radial-frequency') * -1
                radialAmplitude = style.getPropertyValue('--left-radial-amplitude')
            } else if (channelNames[scopeIndex] == "mono") {
                radialFrequency = style.getPropertyValue('--radial-frequency') * -1
                radialAmplitude = style.getPropertyValue('--radial-amplitude')
            }
                
            // We are going to turn this into an SVG path
            const scopePath = []
            const centerX = visualsWidth / 2
            const centerY = visualsHeight / 2
            let volumeWeight = info.average.volume
            const radius = Math.min(centerX, centerY) * (
                radialAmplitude / 100
            ) * volumeWeight
            let angleStep = (Math.PI * 2) / scope.length                
                            
            for (let i = 0; i < scope.length; i++) {
                let angle = angleStep*i
                if (i == (scope.length - 1)) {
                    scopePath.push('z')
                    continue
                }
                const v = scope[i]
                const x = centerX + Math.cos(
                    angleStep * radialFrequency * i
                ) * radius * v                    
                const y = centerY + Math.sin(
                    angleStep * radialFrequency * i
                ) * radius * v
                if (angle === 0) {
                    scopePath.push(``M `${x} `${y}``)
                } else {
                    scopePath.push(``L `${x} `${y}``)
                }
            }
                                    
            // Congratulations, we now have a radial ossiloscope!
            const scopePath2D = new Path2D(scopePath.join(' '))
            // just set the color
            if (channelNames[scopeIndex] == "mono") {

                visualsCanvas2d.strokeStyle = foregroundColor
                visualsCanvas2d.fillStyle = foregroundColor
                if (style.getPropertyValue('--show-radial-scope') <= 0) continue nextScope
                if (style.getPropertyValue('--fill-radial-scope') > 0) {                    
                    visualsCanvas2d.fill(scopePath2D, 'evenodd')
                }
                visualsCanvas2d.stroke(scopePath2D)
            }
            else if (channelNames[scopeIndex] == "right") {
                visualsCanvas2d.strokeStyle = rightColor
                visualsCanvas2d.fillStyle = rightColor
                if (style.getPropertyValue('--show-right-radial') <= 0) continue nextScope
                if (style.getPropertyValue('--fill-right-radial') > 0) {                
                    visualsCanvas2d.fill(scopePath2D, 'evenodd')                
                }
                visualsCanvas2d.stroke(scopePath2D)
            }
            else if (channelNames[scopeIndex] == "left") {
                visualsCanvas2d.strokeStyle = leftColor
                visualsCanvas2d.fillStyle = leftColor
                if (style.getPropertyValue('--show-left-radial') <= 0) continue nextScope
                if (style.getPropertyValue('--fill-left-radial') > 0) {
                    visualsCanvas2d.fill(scopePath2D, 'evenodd')
                }
                visualsCanvas2d.stroke(scopePath2D)
            }                                                
        }                                
        
        if (show.bars || show.volumeCurve) {
            x = 0;            
            const gapWidth = 3
            const barLevels = levels.nonZero
            let barWidth = ((visualsWidth * 1.0) / barLevels.length) - gapWidth
            let barHeight = 0;
            
            let path = []
            let barsPath = []
            for (let i = 0; i < barLevels.length; i++) {
                barHeight = barLevels[i] * visualsHeight * 1/8;                
                let rectTop = visualsHeight - barHeight
                if (show.bars) {
                    visualsCanvas2d.fillStyle = colors.bars;
                    visualsCanvas2d.strokeStyle = colors.curve;
                    visualsCanvas2d.fillRect(x, visualsHeight - barHeight, barWidth, barHeight);
                }                

                if (i == 0 ) {
                    path.push(``M 0 `${visualsHeight}``)
                    path.push(``L `${x} `${rectTop - info.average.low * 4.2}``)
                } else {                    
                    path.push(``L `${x + (barWidth + gapWidth ) / 2} `${rectTop - info.average.low * 4.2}``)
                }
                x += barWidth + gapWidth;
            }                            

            if (show.volumeCurve) {
                let path2d = new Path2D(path.join(' '))
                //path.strokeWidth = 1
                
                if (! show.bars) {
                    visualsCanvas2d.fillStyle = colors.bars
                    visualsCanvas2d.fill(path2d)
                }
                    
                visualsCanvas2d.lineWidth = info.average.volume * 4.2;
                visualsCanvas2d.strokeStyle = colors.curve
                visualsCanvas2d.stroke(path2d)
            }            
        }
    }
    
    draw();
}
for (const input of [...document.body.querySelectorAll('input')]) {
    console.log('Found Input' + input.id)
    input.addEventListener('change', (e) => {
        console.log('Input changed' + e.target.id)
        if (e.target.id && e.target.value) {
            
            if (e.target.type == 'radio' || e.target.type == 'checkbox') {            
                console.log('Setting property:' + e.target.checked)
                document.body.style.setProperty('--' + e.target.id, Number(event.target.checked))
            } else {
                console.log('Setting property on ' + e.target.type + ' : ' + e.target.value)
                document.body.style.setProperty('--' + e.target.id, e.target.value)
            }
            
        }
    })
    if (input.id) {
        if (input.checked) {
            document.body.style.setProperty('--' + input.id, Number(input.checked))
        } else if (input.value) {
            if (input.type == 'color') {
                document.body.style.setProperty('--' + input.id, input.value)
            } else if (new Number(input.value)) {
                document.body.style.setProperty('--' + input.id, Number(input.value)) 
            }
            
        }
        
    }
}
</script>

"@
$html

$OnResize