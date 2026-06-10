$html = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\index.html')
$chunk = $html.Substring(0, 120000)
[regex]::Matches($chunk, 'EFET_elementy[^''"\s]*') | ForEach-Object { $_.Value } | Sort-Object -Unique
Write-Output '--- all png in first 120k ---'
[regex]::Matches($chunk, 'https?://[^''"\s>]+\.png') | ForEach-Object { $_.Value } | Sort-Object -Unique
