$ErrorActionPreference = 'Stop'
$transcript = 'C:\Users\Pasha\.cursor\projects\c-Users-Pasha-efet-studio\agent-transcripts\01aaf169-5ea6-42f0-ae28-0575fd7f54fa\01aaf169-5ea6-42f0-ae28-0575fd7f54fa.jsonl'
$obj = (Get-Content $transcript)[1148] | ConvertFrom-Json
$text = $obj.message.content[0].text
Write-Output "text len=$($text.Length)"
Write-Output "starts: $($text.Substring(0, [Math]::Min(120, $text.Length)))"
Write-Output "has xml decl: $($text -match '<\?xml')"
Write-Output "has svg open: $($text -match '<svg')"
Write-Output "has svg close: $($text -match '</svg>')"
$m = [regex]::Match($text, '(?s)<svg[^>]*viewBox="0 0 488\.04 288\.69".*?</svg>')
Write-Output "svg match len=$($m.Length) value len=$($m.Value.Length)"
