Add-Type -AssemblyName System.Drawing
$p = 'C:\Users\Pasha\efet-studio\assets\hero\metal\torus.png'
$b = [System.Drawing.Bitmap]::FromFile($p)
$t = [System.Drawing.Color]::FromArgb(0,0,0,0)
$n = 0
for($y=0;$y -lt $b.Height;$y++){
  for($x=0;$x -lt $b.Width;$x++){
    $c = $b.GetPixel($x,$y)
    if($c.A -eq 0){ continue }
    [int]$mx = [Math]::Max([Math]::Max($c.R,$c.G),$c.B)
    [int]$mn = [Math]::Min([Math]::Min($c.R,$c.G),$c.B)
    [int]$sat = $mx - $mn
    # any clearly pink pixel (saturated, red-dominant) anywhere, incl. donut hole
    if($sat -gt 22 -and $c.R -gt 170 -and $c.R -gt $c.G -and $c.B -gt $c.G){
      $b.SetPixel($x,$y,$t); $n++
    }
  }
}
$b.Save("$p.tmp.png"); $b.Dispose(); Move-Item -Force "$p.tmp.png" $p
Write-Output "TORUS cleaned: $n px"
