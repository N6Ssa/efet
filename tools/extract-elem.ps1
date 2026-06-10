$b = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\nav-hero-block.html')
$ids = @('176277849369783280','176277899303883020','1771248328332000001','1771248367945000003','1658126384427')
foreach ($id in $ids) {
  Write-Output "======== $id ========"
  $i = $b.IndexOf("data-elem-id='$id'")
  if ($i -lt 0) { $i = $b.IndexOf("data-elem-id=`"$id`"") }
  if ($i -ge 0) {
    $snippet = $b.Substring($i, [Math]::Min(1500, $b.Length - $i))
    Write-Output $snippet
  } else { Write-Output 'NOT FOUND' }
  Write-Output ''
}
