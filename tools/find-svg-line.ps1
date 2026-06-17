$ErrorActionPreference = 'Stop'
$transcript = 'C:\Users\Pasha\.cursor\projects\c-Users-Pasha-efet-studio\agent-transcripts\01aaf169-5ea6-42f0-ae28-0575fd7f54fa\01aaf169-5ea6-42f0-ae28-0575fd7f54fa.jsonl'
$lines = Get-Content $transcript
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match '488\.04 288\.69') {
    Write-Output "line=$($i+1) len=$($lines[$i].Length)"
  }
}
