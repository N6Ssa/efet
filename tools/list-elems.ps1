$b = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\nav-hero-block.html')
$ids = [regex]::Matches($b, 'data-elem-id="([0-9]+)"') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
foreach ($id in $ids) {
  if ($b -match "data-elem-id=`"$id`"[^>]*data-elem-type='([^']+)'") {
    $type = $Matches[1]
  } else { $type = '?' }
  if ($b -match "\[data-elem-id=`"$id`"\]\{[^}]*top:([0-9-]+)px") {
    $top = $Matches[1]
  } else { $top = '?' }
  if ($b -match "\[data-elem-id=`"$id`"\]\{[^}]*left:[^;]*?([0-9-]+)px") {
    $left = $Matches[1]
  } else { $left = '?' }
  Write-Output "$id | $type | top=$top left=$left"
}
