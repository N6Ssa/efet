$html = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\live.html')
$start = $html.IndexOf('id="rec1921353361"')
$end = $html.IndexOf('id="rec1921353381"', $start)
$block = $html.Substring($start, $end - $start)
[regex]::Matches($block, "data-elem-type='([^']+)'") | ForEach-Object { $_.Groups[1].Value } | Group-Object | Format-Table -AutoSize
Write-Output 'vector count:'
([regex]::Matches($block, "data-elem-type='vector'")).Count
Write-Output 'html count:'
([regex]::Matches($block, "data-elem-type='html'")).Count
Write-Output 'all png/gif/svg in nav+hero:'
[regex]::Matches($block, 'https?://[^''"\s>]+\.(png|gif|svg|webp)') | ForEach-Object { $_.Value } | Sort-Object -Unique
