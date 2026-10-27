$ErrorActionPreference = "Stop"

$patterns = @(
  'sb_secret_[A-Za-z0-9_\-]+',
  'service_role',
  'postgresql://[^\s]+:[^\s]+@',
  'SUPABASE_SECRET_KEY\s*[:=]\s*[^\s]+',
  '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
)

$exclude = @(
  '.git',
  'build',
  '.dart_tool',
  'node_modules',
  'config\\prod.json',
  'config/prod.json',
  '.env.example',
  'SECURITY.md',
  'README.md',
  'check-secrets.ps1'
)

$files = Get-ChildItem -Recurse -File | Where-Object {
  $path = $_.FullName
  -not ($exclude | Where-Object { $path -like "*$_*" })
}

$found = $false
foreach ($file in $files) {
  try {
    $content = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction Stop
  } catch {
    continue
  }
  foreach ($pattern in $patterns) {
    if ($content -match $pattern) {
      Write-Host "[ALERTA] Posible secreto en $($file.FullName)" -ForegroundColor Red
      $found = $true
      break
    }
  }
}

if ($found) {
  Write-Host "Se detectaron posibles secretos. Revisa antes de hacer commit." -ForegroundColor Red
  exit 1
}

Write-Host "OK: no se detectaron patrones de secretos de alto riesgo." -ForegroundColor Green
exit 0
