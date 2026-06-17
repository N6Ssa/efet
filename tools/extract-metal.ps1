Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Bitmap]::FromFile('C:\Users\Pasha\efet-studio\assets\reference.png')
$outDir = 'C:\Users\Pasha\efet-studio\assets\hero\metal'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Extract([int]$x,[int]$y,[int]$w,[int]$h,[string]$name) {
  $rect = New-Object System.Drawing.Rectangle($x,$y,$w,$h)
  $crop = $src.Clone($rect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $visited = New-Object 'bool[,]' $w,$h
  $stack = New-Object System.Collections.Generic.Stack[int]
  for($i=0;$i -lt $w;$i++){ $stack.Push($i); $stack.Push(0); $stack.Push($i); $stack.Push($h-1) }
  for($j=0;$j -lt $h;$j++){ $stack.Push(0); $stack.Push($j); $stack.Push($w-1); $stack.Push($j) }
  $transparent = [System.Drawing.Color]::FromArgb(0,0,0,0)
  while($stack.Count -gt 0){
    [int]$py = $stack.Pop()
    [int]$px = $stack.Pop()
    if($px -lt 0 -or $py -lt 0 -or $px -ge $w -or $py -ge $h){ continue }
    if($visited[$px,$py]){ continue }
    $visited[$px,$py] = $true
    $c = $crop.GetPixel($px,$py)
    [int]$mx = [Math]::Max([Math]::Max($c.R,$c.G),$c.B)
    [int]$mn = [Math]::Min([Math]::Min($c.R,$c.G),$c.B)
    [int]$sat = $mx - $mn
    [double]$lum = ($c.R + $c.G + $c.B) / 3
    $isBg = $false
    if ($lum -gt 222 -and $sat -lt 18) { $isBg = $true }
    elseif ($sat -gt 38 -and $c.R -gt 200 -and $c.R -gt $c.G) { $isBg = $true }
    if(-not $isBg){ continue }
    $crop.SetPixel($px,$py,$transparent)
    $stack.Push($px+1); $stack.Push($py)
    $stack.Push($px-1); $stack.Push($py)
    $stack.Push($px); $stack.Push($py+1)
    $stack.Push($px); $stack.Push($py-1)
  }
  $crop.Save("$outDir\$name.png")
  $crop.Dispose()
  Write-Output "$name OK"
}

Extract 168  94  76 74 'sphere'
Extract 258  28  80 90 'cone'
Extract 584 170  88 78 'cube'
Extract 262 337 130 106 'torus'
Extract 586 392 122 90 'blob'
Extract  38 313 204 60 'wave'
Extract  20  20 216 62 'brand-mark'
$src.Dispose()
Write-Output 'ALL DONE'
