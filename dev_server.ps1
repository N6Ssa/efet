$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Port = 5173
$State = [hashtable]::Synchronized(@{ Version = 0 })

$WatchExtensions = @('.html', '.css', '.js', '.svg', '.png', '.jpg', '.jpeg', '.webp', '.gif')

$ReloadScript = @'
<script>
(function () {
  let last = 0;
  setInterval(async function () {
    try {
      const res = await fetch('/__reload');
      const data = await res.json();
      if (last && data.version !== last) location.reload();
      last = data.version;
    } catch (_) {}
  }, 800);
})();
</script>
'@

function Get-ContentType([string]$Path) {
    switch ([IO.Path]::GetExtension($Path).ToLower()) {
        '.html' { return 'text/html; charset=utf-8' }
        '.css'  { return 'text/css; charset=utf-8' }
        '.js'   { return 'application/javascript; charset=utf-8' }
        '.svg'  { return 'image/svg+xml' }
        '.png'  { return 'image/png' }
        '.jpg'  { return 'image/jpeg' }
        '.jpeg' { return 'image/jpeg' }
        '.webp' { return 'image/webp' }
        '.gif'  { return 'image/gif' }
        '.json' { return 'application/json; charset=utf-8' }
        default { return 'application/octet-stream' }
    }
}

function Send-Response($Context, [int]$StatusCode, [string]$ContentType, [byte[]]$Body) {
    $response = $Context.Response
    $response.StatusCode = $StatusCode
    $response.ContentType = $ContentType
    $response.Headers.Add('Cache-Control', 'no-store')
    $response.ContentLength64 = $Body.Length
    $response.OutputStream.Write($Body, 0, $Body.Length)
    $response.OutputStream.Close()
}

function Resolve-RequestPath([string]$UrlPath) {
    $decoded = [Uri]::UnescapeDataString($UrlPath)
    if ($decoded -eq '/' -or $decoded -eq '') {
        return Join-Path $Root 'index.html'
    }

    $relative = $decoded.TrimStart('/').Replace('/', [IO.Path]::DirectorySeparatorChar)
    $candidate = Join-Path $Root $relative
    $fullRoot = [IO.Path]::GetFullPath($Root)
    $fullCandidate = [IO.Path]::GetFullPath($candidate)

    if (-not $fullCandidate.StartsWith($fullRoot, [StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }

    if (Test-Path $fullCandidate -PathType Leaf) {
        return $fullCandidate
    }

    return $null
}

$Watcher = New-Object IO.FileSystemWatcher
$Watcher.Path = $Root
$Watcher.IncludeSubdirectories = $true
$Watcher.EnableRaisingEvents = $true
$Watcher.Filter = '*.*'

Register-ObjectEvent -InputObject $Watcher -EventName Changed -MessageData $State -Action {
    $ext = [IO.Path]::GetExtension($Event.SourceEventArgs.Name).ToLower()
    $allowed = @('.html', '.css', '.js', '.svg', '.png', '.jpg', '.jpeg', '.webp', '.gif')
    if ($allowed -contains $ext) {
        $Event.MessageData.Version++
        Write-Host "[reload] Changed: $($Event.SourceEventArgs.Name)"
    }
} | Out-Null

Register-ObjectEvent -InputObject $Watcher -EventName Created -MessageData $State -Action {
    $Event.MessageData.Version++
} | Out-Null

Register-ObjectEvent -InputObject $Watcher -EventName Renamed -MessageData $State -Action {
    $Event.MessageData.Version++
} | Out-Null

$Listener = New-Object System.Net.HttpListener
$Listener.Prefixes.Add("http://127.0.0.1:$Port/")
$Listener.Start()

Write-Host "EFET Studio dev server: http://127.0.0.1:$Port"
Write-Host "Edit files and save - the page reloads automatically."
Write-Host "Press Ctrl+C to stop."

try {
    while ($Listener.IsListening) {
        $context = $Listener.GetContext()
        try {
        $path = $context.Request.Url.AbsolutePath

        if ($path -eq '/__reload') {
            $json = "{ `"version`": $($State.Version) }"
            Send-Response $context 200 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes($json))
            continue
        }

        $filePath = Resolve-RequestPath $path
        if (-not $filePath) {
            Send-Response $context 404 'text/plain; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('Not Found'))
            continue
        }

        try {
            $bytes = [IO.File]::ReadAllBytes($filePath)
        } catch {
            Write-Host "[warn] Could not read $filePath (file may be locked): $($_.Exception.Message)"
            Send-Response $context 503 'text/plain; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('File temporarily unavailable. Retry in a moment.'))
            continue
        }

        if ([IO.Path]::GetExtension($filePath).ToLower() -eq '.html') {
            $html = [Text.Encoding]::UTF8.GetString($bytes)
            if ($html -match '</body>') {
                $html = $html -replace '</body>', ($ReloadScript + '</body>')
                $bytes = [Text.Encoding]::UTF8.GetBytes($html)
            }
        }

        Send-Response $context 200 (Get-ContentType $filePath) $bytes
        } catch {
            Write-Host "[error] Request failed: $($_.Exception.Message)"
            try {
                Send-Response $context 500 'text/plain; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('Internal Server Error'))
            } catch {}
        }
    }
}
finally {
    $Listener.Stop()
    $Watcher.EnableRaisingEvents = $false
    $Watcher.Dispose()
}
