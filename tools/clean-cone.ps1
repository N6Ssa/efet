Add-Type -AssemblyName System.Drawing
$p = 'C:\Users\Pasha\efet-studio\assets\hero\metal\cone.png'
$b = [System.Drawing.Bitmap]::FromFile($p)
$w = $b.Width; $h = $b.Height
$toClear = New-Object System.Collections.Generic.List[int]
for($y=3;$y -lt ($h-3);$y++){
  for($x=0;$x -lt $w;$x++){
    if($b.GetPixel($x,$y).A -eq 0){ continue }
    if($b.GetPixel($x,$y-3).A -eq 0 -and $b.GetPixel($x,$y+3).A -eq 0){
      $toClear.Add($x); $toClear.Add($y)
    }
  }
}
$transparent = [System.Drawing.Color]::FromArgb(0,0,0,0)
for($i=0;$i -lt $toClear.Count;$i+=2){
  $b.SetPixel($toClear[$i],$toClear[$i+1],$transparent)
}
$tmp = "$p.tmp.png"
$b.Save($tmp)
$b.Dispose()
Move-Item -Force $tmp $p
Write-Output "CLEANED $($toClear.Count/2) px"
