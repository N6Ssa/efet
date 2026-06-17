Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Bitmap]::FromFile('C:\Users\Pasha\efet-studio\assets\reference.png')
$x=202;$y=170;$w=546;$h=180
$rect = New-Object System.Drawing.Rectangle($x,$y,$w,$h)
$crop = $src.Clone($rect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$transparent = [System.Drawing.Color]::FromArgb(0,0,0,0)

# erase cube zone (it is a separate element): abs 580..676, 168..252 -> rel 380..476, 0..76
for($j=0;$j -le 76;$j++){
  for($i=378;$i -lt 478;$i++){
    if($i -lt $w -and $j -lt $h){ $crop.SetPixel($i,$j,$transparent) }
  }
}
# erase torus sliver zone bottom-left: abs 260..394, 335..348 -> rel 60..194, 159..171
for($j=157;$j -lt $h;$j++){
  for($i=55;$i -le 200;$i++){
    $crop.SetPixel($i,$j,$transparent)
  }
}

# flood-fill key: white + pink backgrounds from borders
$visited = New-Object 'bool[,]' $w,$h
$stack = New-Object System.Collections.Generic.Stack[int]
for($i=0;$i -lt $w;$i++){ $stack.Push($i); $stack.Push(0); $stack.Push($i); $stack.Push($h-1) }
for($j=0;$j -lt $h;$j++){ $stack.Push(0); $stack.Push($j); $stack.Push($w-1); $stack.Push($j) }
while($stack.Count -gt 0){
  [int]$py = $stack.Pop()
  [int]$px = $stack.Pop()
  if($px -lt 0 -or $py -lt 0 -or $px -ge $w -or $py -ge $h){ continue }
  if($visited[$px,$py]){ continue }
  $visited[$px,$py] = $true
  $c = $crop.GetPixel($px,$py)
  $isBg = $false
  if($c.A -eq 0){ $isBg = $true }
  else {
    [int]$mx = [Math]::Max([Math]::Max($c.R,$c.G),$c.B)
    [int]$mn = [Math]::Min([Math]::Min($c.R,$c.G),$c.B)
    [int]$sat = $mx - $mn
    [double]$lum = ($c.R + $c.G + $c.B) / 3
    if ($lum -gt 215 -and $sat -lt 18) { $isBg = $true }
    elseif ($sat -gt 30 -and $c.R -gt 180 -and $c.R -gt $c.G) { $isBg = $true }
  }
  if(-not $isBg){ continue }
  if($c.A -ne 0){ $crop.SetPixel($px,$py,$transparent) }
  $stack.Push($px+1); $stack.Push($py)
  $stack.Push($px-1); $stack.Push($py)
  $stack.Push($px); $stack.Push($py+1)
  $stack.Push($px); $stack.Push($py-1)
}
$crop.Save('C:\Users\Pasha\efet-studio\assets\hero\metal\wordmark.png')
$crop.Dispose()
$src.Dispose()
Write-Output 'WORDMARK OK'
