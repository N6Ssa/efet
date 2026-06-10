$html = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\live.html')
[regex]::Matches($html, 'https://[^''"\s>]+') | ForEach-Object { $_.Value } | Where-Object { $_ -match 'tild|static' } | Sort-Object -Unique | Where-Object { $_ -match 'elementy|hero|3d|figure|metal|chrome|sphere|cone|torus|cube|blob|logo' }
