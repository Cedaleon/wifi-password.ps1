# Verifica la versión de PowerShell y que se está ejecutando en un equipo con Windows
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "Este script requiere PowerShell 3.0 o posterior." -ForegroundColor Red
    return
}

if (-not (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\")) {
    Write-Host "Este script solo se puede ejecutar en un equipo con Windows." -ForegroundColor Red
    return
}

# Descarga el archivo wifi-password.ps1 desde el enlace proporcionado
$url = "https://raw.githubusercontent.com/Cedaleon/wifi-password.ps1/main/script_descarga_claves_wifi.ps1"
$archivo = "claves_wifi.txt"

# Verifica si el archivo de salida ya existe y pide confirmación antes de sobrescribirlo
if (Test-Path $archivo) {
    $confirm = Read-Host "El archivo $archivo ya existe. ¿Desea sobrescribirlo? (S/N)"
    if ($confirm -ne 'S') {
        Write-Host "Operación cancelada." -ForegroundColor Yellow
        return
    }
}

# Descarga el archivo wifi-password.ps1 desde el enlace proporcionado
try {
    $response = Invoke-WebRequest -Uri $url -Method Get -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Host "Error al descargar el archivo: $_" -ForegroundColor Red
    return
}

if ($response.StatusCode -eq 200) {
    $response.Content | Out-File wifi-password.ps1
} else {
    Write-Host "No se pudo descargar el archivo. Código de estado HTTP: $($response.StatusCode)" -ForegroundColor Red
    return
}

# Elimina el archivo de salida si ya existe
if (Test-Path -Path $archivo) {
    Remove-Item $archivo
}

# Ejecuta el script wifi-password.ps1 y guarda la salida en el archivo de salida
try {
    .\wifi-password.ps1 | Out-File -FilePath $archivo
} catch {
    Write-Host "Error al ejecutar el script: $_" -ForegroundColor Red
    return
}
