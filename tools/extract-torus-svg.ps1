$transcript = 'C:\Users\Pasha\.cursor\projects\c-Users-Pasha-efet-studio\agent-transcripts\01aaf169-5ea6-42f0-ae28-0575fd7f54fa\01aaf169-5ea6-42f0-ae28-0575fd7f54fa.jsonl'
$out = 'C:\Users\Pasha\efet-studio\assets\hero\torus-illustrator.svg'
$metal = 'C:\Users\Pasha\efet-studio\assets\metal-torus.svg'
$obj = (Get-Content $transcript)[1148] | ConvertFrom-Json
$text = $obj.message.content[0].text
$svg = ([regex]::Match($text, '(?s)<\?xml.*?</svg>')).Value
[IO.File]::WriteAllText($out, $svg, [Text.UTF8Encoding]::new($false))
Copy-Item $out $metal -Force
Write-Output "Saved $($svg.Length) chars"
