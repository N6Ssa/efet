$transcript = 'C:\Users\Pasha\.cursor\projects\c-Users-Pasha-efet-studio\agent-transcripts\01aaf169-5ea6-42f0-ae28-0575fd7f54fa\01aaf169-5ea6-42f0-ae28-0575fd7f54fa.jsonl'
$lines = Get-Content $transcript
foreach ($n in 1149,1151,1153,1157) {
  $obj = $lines[$n - 1] | ConvertFrom-Json
  $t = $obj.message.content[0].text
  $close = $t.Contains('</svg>')
  $fillStyle = $t.Contains('fill: #342d2f')
  $clipStyle = $t.Contains('clip-path: url(#clippath')
  Write-Output "line $n len=$($t.Length) close=$close fill342d2f=$fillStyle clip=$clipStyle"
}
