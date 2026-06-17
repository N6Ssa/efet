Add-Type -AssemblyName System.Drawing
$transparent = [System.Drawing.Color]::FromArgb(0,0,0,0)

# 1) Wordmark: keep only dark letterforms
$p = 'C:\Users\Pasha\efet-studio\assets\hero\metal\wordmark.png'
$b = [System.Drawing.Bitmap]::FromFile($p)
for($y=0;$y -lt $b.Height;$y++){
  for($x=0;$x -lt $b.Width;$x++){
    $c = $b.GetPixel($x,$y)
    if($c.A -eq 0){ continue }
    [double]$lum = ($c.R + $c.G + $c.B) / 3
    if($lum -gt 150){ $b.SetPixel($x,$y,$transparent) }
  }
}
$b.Save("$p.tmp.png"); $b.Dispose(); Move-Item -Force "$p.tmp.png" $p
Write-Output 'wordmark cleaned'

# 2) Metal PNGs: erode light/pink halo connected to transparent areas
foreach($name in @('sphere','cone','cube','torus','blob','wave','brand-mark')){
  $p = "C:\Users\Pasha\efet-studio\assets\hero\metal\$name.png"
  $b = [System.Drawing.Bitmap]::FromFile($p)
  $w = $b.Width; $h = $b.Height
  $changed = $true
  $pass = 0
  while($changed -and $pass -lt 25){
    $changed = $false
    $pass++
    $kill = New-Object System.Collections.Generic.List[int]
    for($y=0;$y -lt $h;$y++){
      for($x=0;$x -lt $w;$x++){
        $c = $b.GetPixel($x,$y)
        if($c.A -eq 0){ continue }
        $nearTransparent = $false
        if($x -eq 0 -or $y -eq 0 -or $x -eq ($w-1) -or $y -eq ($h-1)){ $nearTransparent = $true }
        else {
          if($b.GetPixel($x-1,$y).A -eq 0 -or $b.GetPixel($x+1,$y).A -eq 0 -or $b.GetPixel($x,$y-1).A -eq 0 -or $b.GetPixel($x,$y+1).A -eq 0){ $nearTransparent = $true }
        }
        if(-not $nearTransparent){ continue }
        [int]$mx = [Math]::Max([Math]::Max($c.R,$c.G),$c.B)
        [int]$mn = [Math]::Min([Math]::Min($c.R,$c.G),$c.B)
        [int]$sat = $mx - $mn
        [double]$lum = ($c.R + $c.G + $c.B) / 3
        $isHalo = $false
        if($lum -gt 205 -and $sat -lt 50){ $isHalo = $true }
        elseif($sat -gt 25 -and $c.R -gt 180 -and $c.R -gt $c.G){ $isHalo = $true }
        if($isHalo){ $kill.Add($x); $kill.Add($y); $changed = $true }
      }
    }
    for($i=0;$i -lt $kill.Count;$i+=2){ $b.SetPixel($kill[$i],$kill[$i+1],$transparent) }
  }
  $b.Save("$p.tmp.png"); $b.Dispose(); Move-Item -Force "$p.tmp.png" $p
  Write-Output "$name cleaned ($pass passes)"
}
Write-Output 'ALL CLEAN'
