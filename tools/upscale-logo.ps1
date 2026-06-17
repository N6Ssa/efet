Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Bitmap]::FromFile('C:\Users\Pasha\.cursor\projects\c-Users-Pasha-efet-studio\assets\c__Users_Pasha_AppData_Roaming_Cursor_User_workspaceStorage_empty-window_images_EFET_WEB_logo-0b5ca955-2a0a-490d-8b7d-600479874da1.png')

# check counter pixels (letter holes) for stray white
foreach($pt in @(@(63,50),@(150,50),@(255,40),@(300,80))){
  $c=$src.GetPixel($pt[0],$pt[1])
  Write-Output "px $($pt[0]),$($pt[1]): A=$($c.A) R=$($c.R)"
}

# 4x high-quality upscale
[int]$w = $src.Width * 4
[int]$h = $src.Height * 4
$big = New-Object System.Drawing.Bitmap($w,$h,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($big)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.DrawImage($src,0,0,$w,$h)
$g.Dispose()

# crisp edges: flat brand color + alpha contrast curve
for($y=0;$y -lt $h;$y++){
  for($x=0;$x -lt $w;$x++){
    $c = $big.GetPixel($x,$y)
    if($c.A -eq 0){ continue }
    [double]$a = $c.A
    [double]$na = ($a - 70) / (185 - 70) * 255
    if($na -lt 0){ $na = 0 } elseif($na -gt 255){ $na = 255 }
    $big.SetPixel($x,$y,[System.Drawing.Color]::FromArgb([int]$na,43,42,41))
  }
}
$big.Save('C:\Users\Pasha\efet-studio\assets\hero\metal\wordmark.png')
$big.Dispose()
$src.Dispose()
Write-Output "LOGO OK ${w}x${h}"
