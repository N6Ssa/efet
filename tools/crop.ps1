Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Bitmap]::FromFile('C:\Users\Pasha\efet-studio\assets\reference.png')
function Crop($x,$y,$w,$h,$name){
  $r = New-Object System.Drawing.Rectangle($x,$y,$w,$h)
  $c = $src.Clone($r, $src.PixelFormat)
  $c.Save("C:\Users\Pasha\efet-studio\tools\crops\$name.png")
  $c.Dispose()
}
New-Item -ItemType Directory -Force -Path 'C:\Users\Pasha\efet-studio\tools\crops' | Out-Null
Crop 0 0 1024 130 'top-header'
Crop 0 0 300 140 'brand-mark'
Crop 130 60 280 200 'sphere-cone'
Crop 540 150 200 130 'cube'
Crop 30 290 280 130 'wave'
Crop 240 320 220 130 'torus'
Crop 560 390 180 110 'blob'
Crop 20 455 1004 124 'bottom-panel'
Crop 180 130 620 270 'logo-zone'
$src.Dispose()
Write-Output 'DONE'
