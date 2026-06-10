$block = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\hero-block.html')
$matches = [regex]::Matches($block, "<div class='t396__elem[^>]*data-elem-type='shape'[^>]*>[\s\S]*?</div>\s*</div>")
$i = 0
foreach ($m in $matches) {
  $i++
  $snippet = $m.Value
  if ($snippet.Length -gt 1200) { $snippet = $snippet.Substring(0, 1200) + '...' }
  Write-Output "=== shape $i ==="
  Write-Output $snippet
  Write-Output ''
}
