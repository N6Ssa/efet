$html = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\live.html')
$start = $html.IndexOf('id="rec2024319931"')
$end = $html.IndexOf('id="rec1921353381"', $start)
$block = $html.Substring($start, $end - $start)
Write-Output "hero block length: $($block.Length)"
[regex]::Matches($block, "data-elem-type='([^']+)'") | ForEach-Object { $_.Groups[1].Value } | Group-Object | Format-Table -AutoSize
Write-Output '--- all urls ---'
[regex]::Matches($block, 'https?://[^''"\s>]+\.(png|gif|svg|webp|jpg)') | ForEach-Object { $_.Value } | Sort-Object -Unique
