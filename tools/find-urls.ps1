$b = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\nav-hero-block.html')
[regex]::Matches($b, 'url\(([^)]+)\)') | ForEach-Object { $_.Groups[1].Value.Trim('"', "'") } | Sort-Object -Unique
