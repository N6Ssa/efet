$b = [IO.File]::ReadAllText('C:\Users\Pasha\efet-studio\tools\nav-hero-block.html')
$ids = @('1763717199563','1762778939167','176277899303883020','1773129705897','1762778091424','1771231198195')
foreach ($id in $ids) {
  if ($b -match "\[data-elem-id=`"$id`"\]\{([^}]+)\}") {
    Write-Output "$id :: $($Matches[1].Substring(0, [Math]::Min(120, $Matches[1].Length)))"
  }
}
