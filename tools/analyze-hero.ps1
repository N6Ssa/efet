$block = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\hero-block.html')
$m = [regex]::Matches($block, "data-elem-type='([^']+)'")
$m | ForEach-Object { $_.Groups[1].Value } | Group-Object | Format-Table -AutoSize
Write-Output '--- images ---'
[regex]::Matches($block, "src='([^']+)'") | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
Write-Output '--- data-original ---'
[regex]::Matches($block, "data-original='([^']+)'") | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
