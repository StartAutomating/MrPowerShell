
$sequenceSteps = @(
    'M180 142' # The inner top location of the butterfly
    'c-16.3 -31.7 -60.7 -90.8 -102 -120' # left wing curve
    'C38.5 -5.9 23.4-1 13.5 3.4' # upper wing top tip
    '2.1 8.6 0 26.2 0 36.5' # upper wing left tip
    'c0 10.4 5.7 84.8 9.4 97.2 12.2' # upper left wing
    '41 55.7 55 95.7 50.5-58.7' # upper left wing inward curve
    '8.6-110.8 30-42.4 106.1 75.1' # lower left outward curve
    '77.9 103-16.7 117.3-64.6 14.3' # lower left inward curve
    '48 30.8 139 116 64.6 64-64.6' # lower right inward curve
    '17.6-97.5-41.1-106.1 40 4.4' # lower right outward curve
    '83.5-9.5 95.7-50.5 3.7-12.4' # upper right outward curve
    '9.4-86.8 9.4-97.2 0-10.3' # upper right side curve
    '-2-27.9-13.5-33' # upper right top tip
    'C336.5-1 321.5-6 282 22' # upper right top edge 
    'c-41.3 29.2-85.7 88.3-102 120' # upper right inward curve
    'Z'
) -join ' '

@"
<svg xmlns="http://www.w3.org/2000/svg" viewBox='0 0 24 24' width='24' height='24' class='foreground-stroke'>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 320"><path stroke="#0085ff" class='foreground-stroke foreground-fill' d="$SequenceSteps" stroke-width="6.66%" stroke-linecap="round" /></svg>
</svg>
"@ > $psScriptRoot/BlueSky.svg