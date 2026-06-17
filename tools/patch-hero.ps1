$index = 'C:\Users\Pasha\efet-studio\index.html'
$snippet = Get-Content 'C:\Users\Pasha\efet-studio\src\hero-snippet.html' -Raw -Encoding UTF8
$html = Get-Content $index -Raw -Encoding UTF8
$pattern = '(?s)<div class="hero-viewport">.*?</div>\s*(?=</div>\s*<!--/allrecords-->|</div>\s*<div id="rec)'
if ($html -match $pattern) {
  $html = [regex]::Replace($html, $pattern, ($snippet.TrimEnd() + "`n"))
  [IO.File]::WriteAllText($index, $html, [Text.UTF8Encoding]::new($false))
  Write-Output 'Hero patched OK'
} else {
  Write-Error 'Hero block not found'
  exit 1
}
