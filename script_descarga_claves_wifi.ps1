$url = "https://github.com/Cedaleon/wifi-password.ps1/blob/main/script_descarga_claves_wifi.ps1"
$archivo = "claves_wifi.txt"

$response = Invoke-WebRequest -Uri $url -Method Get -ErrorAction Stop
if ($response.StatusCode -eq 200) {
    $response.Content | Out-File wifi-password.ps1
}
else {
    Write-Host "No se pudo descargar el archivo. Código de estado HTTP: $($response.StatusCode)" -ForegroundColor Red
}

if (Test-Path -Path $archivo) {
    Remove-Item $archivo
}

.\wifi-password.ps1 | Out-File -FilePath $archivo
