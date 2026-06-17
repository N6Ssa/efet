$ErrorActionPreference = 'Stop'
$transcript = 'C:\Users\Pasha\.cursor\projects\c-Users-Pasha-efet-studio\agent-transcripts\01aaf169-5ea6-42f0-ae28-0575fd7f54fa\01aaf169-5ea6-42f0-ae28-0575fd7f54fa.jsonl'
$outDir = 'C:\Users\Pasha\efet-studio\public\graphics'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$out = Join-Path $outDir 'efet-web-elements.svg'
$obj = (Get-Content $transcript)[1148] | ConvertFrom-Json
$text = $obj.message.content[0].text
$svg = ([regex]::Match($text, '(?s)<\?xml.*?</svg>')).Value
if (-not $svg) { throw 'SVG not found in transcript line 1149' }
[IO.File]::WriteAllText($out, $svg, [Text.UTF8Encoding]::new($false))
Write-Output "Saved $($svg.Length) chars -> $out"
Select-String -Path $out -Pattern 'viewBox' | Select-Object -First 1
