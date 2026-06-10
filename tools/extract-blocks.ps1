$html = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\index.html')
$ids = @('rec1921353361','rec2024319931','rec1921353381')
foreach ($id in $ids) {
  $pattern = "id=`"$id`""
  $i = $html.IndexOf($pattern)
  Write-Output "=== $id index=$i ==="
  if ($i -ge 0) {
    Write-Output $html.Substring($i, [Math]::Min(2500, $html.Length - $i))
    Write-Output ""
  }
}
