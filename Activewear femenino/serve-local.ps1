$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 8000
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $port)
$listener.Start()

Write-Host "Servidor local activo en http://localhost:$port/"
Write-Host "Carpeta: $root"

$contentTypes = @{
  ".html" = "text/html; charset=utf-8"
  ".css" = "text/css; charset=utf-8"
  ".js" = "application/javascript; charset=utf-8"
  ".png" = "image/png"
  ".jpg" = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".svg" = "image/svg+xml"
}

function Send-Response($stream, $status, $contentType, [byte[]]$body) {
  $header = "HTTP/1.1 $status`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nConnection: close`r`n`r`n"
  $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
  $stream.Write($headerBytes, 0, $headerBytes.Length)
  $stream.Write($body, 0, $body.Length)
}

while ($true) {
  $client = $listener.AcceptTcpClient()
  $stream = $client.GetStream()
  $buffer = New-Object byte[] 4096
  $read = $stream.Read($buffer, 0, $buffer.Length)
  $request = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $read)
  $firstLine = ($request -split "`r`n")[0]
  $parts = $firstLine -split " "
  $urlPath = if ($parts.Length -ge 2) { $parts[1] } else { "/" }

  if ($urlPath -eq "/") {
    $urlPath = "/index.html"
  }

  $relativePath = [Uri]::UnescapeDataString($urlPath.TrimStart("/")).Replace("/", [System.IO.Path]::DirectorySeparatorChar)
  $localPath = [System.IO.Path]::GetFullPath((Join-Path $root $relativePath))
  $rootPath = [System.IO.Path]::GetFullPath($root)

  if ($localPath.StartsWith($rootPath) -and (Test-Path -LiteralPath $localPath -PathType Leaf)) {
    $body = [System.IO.File]::ReadAllBytes($localPath)
    $extension = [System.IO.Path]::GetExtension($localPath).ToLowerInvariant()
    $contentType = if ($contentTypes.ContainsKey($extension)) { $contentTypes[$extension] } else { "application/octet-stream" }
    Send-Response $stream "200 OK" $contentType $body
  } else {
    $body = [System.Text.Encoding]::UTF8.GetBytes("No encontrado")
    Send-Response $stream "404 Not Found" "text/plain; charset=utf-8" $body
  }

  $stream.Close()
  $client.Close()
}
