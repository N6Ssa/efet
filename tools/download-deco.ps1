$dest = 'C:\Users\Pasha\efet-studio\assets\hero\deco'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$files = @{
  'sphere.png' = 'https://static.tildacdn.com/tild3934-3539-4332-b965-653332666636/EFET_elementy_17.png'
  'cube.png'   = 'https://static.tildacdn.com/tild3733-3931-4131-b966-633538643562/EFET_elementy_18.png'
  'blob.png'   = 'https://static.tildacdn.com/tild3732-6238-4631-b964-613538383739/EFET_elementy_19.png'
  'deco8.png'  = 'https://static.tildacdn.com/tild3265-6332-4730-a361-653038663132/EFET_elementy_8.png'
  'nav-mark.svg' = 'https://static.tildacdn.com/tild6532-3430-4131-a166-346165653764/EFET_elementy_16.svg'
  'logo.gif'   = 'https://static.tildacdn.com/tild3061-3737-4232-b639-613965376537/EFET_logo_gif.gif'
}

foreach ($name in $files.Keys) {
  $out = Join-Path $dest $name
  Invoke-WebRequest -Uri $files[$name] -OutFile $out -UseBasicParsing
  Write-Output "saved $name"
}
