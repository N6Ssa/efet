Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile('C:\Users\Pasha\efet-studio\assets\reference.png')
$W = $bmp.Width; $H = $bmp.Height

function Scan-Dark($x0,$y0,$x1,$y1,$thresh=80) {
  $minX=99999;$minY=99999;$maxX=-1;$maxY=-1
  for($y=$y0;$y -le $y1;$y++){
    for($x=$x0;$x -le $x1;$x++){
      if($x -ge $W -or $y -ge $H){ continue }
      $p=$bmp.GetPixel($x,$y)
      if($p.R -lt $thresh -and $p.G -lt $thresh -and $p.B -lt $thresh){
        if($x -lt $minX){$minX=$x}; if($x -gt $maxX){$maxX=$x}
        if($y -lt $minY){$minY=$y}; if($y -gt $maxY){$maxY=$y}
      }
    }
  }
  if($maxX -lt 0){ return 'none' }
  "$minX,$minY -> $maxX,$maxY (w=$($maxX-$minX) h=$($maxY-$minY))"
}

Write-Output "IMG: ${W}x${H}"
Write-Output "HEADER BAR top: $(Scan-Dark 0 0 ($W-1) 80)"
Write-Output "HEADER BAR narrow: $(Scan-Dark 250 10 780 60)"
Write-Output "ORANGE BTN: $(Scan-Dark 680 20 920 70 200)"
Write-Output "PHONE zone: $(Scan-Dark 380 20 520 50)"
Write-Output "BOTTOM PANEL: $(Scan-Dark 30 450 ($W-30) ($H-1))"
$bmp.Dispose()
