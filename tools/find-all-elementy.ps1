$html = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\live.html')
[regex]::Matches($html, 'https://static\.tildacdn\.com/[^''"\s>]+EFET_elementy[^''"\s>]+') | ForEach-Object { $_.Value } | Sort-Object -Unique
