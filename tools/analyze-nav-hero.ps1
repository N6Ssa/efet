$b = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\nav-hero-block.html')
[regex]::Matches($b, "data-elem-type='([^']+)'") | ForEach-Object { $_.Groups[1].Value } | Group-Object | Format-Table -AutoSize
Write-Output '--- data-original ---'
[regex]::Matches($b, "data-original='([^']+)'") | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
Write-Output '--- src ---'
[regex]::Matches($b, "src='([^']+)'") | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
