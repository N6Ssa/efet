$html = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\index.html')
$start = $html.IndexOf('id="rec1921353361"')
$end = $html.IndexOf('id="rec1921353381"', $start)
$block = $html.Substring($start, $end - $start)
Write-Output "Block length: $($block.Length)"
[regex]::Matches($block, 'https?://[^''"\s>]+\.(png|gif|svg|webp|jpg|jpeg)') | ForEach-Object { $_.Value } | Sort-Object -Unique
Write-Output "--- elem types ---"
[regex]::Matches($block, "data-elem-type='([^']+)'") | ForEach-Object { $_.Groups[1].Value } | Group-Object | Sort-Object Count -Descending | Select-Object -First 15
