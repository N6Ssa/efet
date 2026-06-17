Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile('C:\Users\Pasha\efet-studio\assets\reference.png')

function Scan-Dark($x0,$y0,$x1,$y1,$thresh=80) {
  $minX=99999;$minY=99999;$maxX=-1;$maxY=-1
  for($y=$y0;$y -le $y1;$y+=2){
    for($x=$x0;$x -le $x1;$x+=2){
      $p=$bmp.GetPixel($x,$y)
      if($p.R -lt $thresh -and $p.G -lt $thresh -and $p.B -lt $thresh){
        if($x -lt $minX){$minX=$x}; if($x -gt $maxX){$maxX=$x}
        if($y -lt $minY){$minY=$y}; if($y -gt $maxY){$maxY=$y}
      }
    }
  }
  "$minX,$minY -> $maxX,$maxY (w=$($maxX-$minX) h=$($maxY-$minY))"
}

function Scan-Orange($x0,$y0,$x1,$y1) {
  $minX=99999;$minY=99999;$maxX=-1;$maxY=-1
  for($y=$y0;$y -le $y1;$y++){
    for($x=$x0;$x -le $x1;$x++){
      $p=$bmp.GetPixel($x,$y)
      if($p.R -gt 190 -and $p.G -gt 80 -and $p.G -lt 160 -and $p.B -lt 90){
        if($x -lt $minX){$minX=$x}; if($x -gt $maxX){$maxX=$x}
        if($y -lt $minY){$minY=$y}; if($y -gt $maxY){$maxY=$y}
      }
    }
  }
  "$minX,$minY -> $maxX,$maxY (w=$($maxX-$minX) h=$($maxY-$minY))"
}

Write-Output "ORANGE BTN (top right): $(Scan-Orange 650 10 1024 90)"
Write-Output "BRAND MARK (top-left dark): $(Scan-Dark 0 0 260 120)"
Write-Output "BOTTOM PANEL col1: $(Scan-Dark 30 470 215 579)"
Write-Output "BOTTOM PANEL full: $(Scan-Dark 20 460 1010 579)"
Write-Output "EFET LOGO dark zone: $(Scan-Dark 200 170 800 350)"
Write-Output "KICKER text: $(Scan-Dark 230 145 560 175)"
Write-Output "SUBTITLE text: $(Scan-Dark 400 345 700 395)"
Write-Output "CUBE zone gray: "
# cube is gray; use mid-gray detection
$minX=99999;$minY=99999;$maxX=-1;$maxY=-1
for($y=170;$y -le 260;$y++){
  for($x=580;$x -le 700;$x++){
    $p=$bmp.GetPixel($x,$y)
    $avg = ($p.R+$p.G+$p.B)/3
    $sat = [Math]::Max([Math]::Max($p.R,$p.G),$p.B) - [Math]::Min([Math]::Min($p.R,$p.G),$p.B)
    if($avg -gt 90 -and $avg -lt 220 -and $sat -lt 25){
      if($x -lt $minX){$minX=$x}; if($x -gt $maxX){$maxX=$x}
      if($y -lt $minY){$minY=$y}; if($y -gt $maxY){$maxY=$y}
    }
  }
}
Write-Output "  $minX,$minY -> $maxX,$maxY (w=$($maxX-$minX) h=$($maxY-$minY))"
$bmp.Dispose()
