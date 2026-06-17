Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile('C:\Users\Pasha\efet-studio\assets\reference.png')
Write-Output "$($bmp.Width)x$($bmp.Height)"
$bmp.Dispose()
