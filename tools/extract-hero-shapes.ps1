$html = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\index.html')
$start = $html.IndexOf('id="rec2024319931"')
$end = $html.IndexOf('id="rec1921353381"', $start)
$block = $html.Substring($start, $end - $start)
[regex]::Matches($block, "data-elem-type='([^']+)'") | ForEach-Object { $_.Groups[1].Value } | Group-Object
[regex]::Matches($block, 'data-original=''([^'']+)''') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
[regex]::Matches($block, "data-field-filewidth-value=\"([0-9]+)\"") | Select-Object -First 10
