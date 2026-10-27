$ErrorActionPreference = "Stop"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host "Flutter no esta en PATH. Instala Flutter estable y vuelve a ejecutar este script." -ForegroundColor Red
  exit 1
}

Set-Location $PSScriptRoot
flutter create --platforms=android --org org.adaazul --project-name ada_azul .
flutter pub get
flutter analyze
flutter build apk --debug
Write-Host "APK: build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor Green
