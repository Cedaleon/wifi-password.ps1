# Verifica la versión de PowerShell y que se está ejecutando en un equipo con Windows
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "Este script requiere PowerShell 3.0 o posterior." -ForegroundColor Red
    return
}

if (-not (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion")) {
    Write-Host "Este script solo se puede ejecutar en un equipo con Windows." -ForegroundColor Red
    return
}

# Verificar si el equipo está conectado a una red Wi-Fi
$wifi_adapter = Get-NetAdapter | Where-Object { $_.MediaType -eq 'WiFi' -and $_.Status -eq 'Up' } | Select-Object -First 1
if ($wifi_adapter -eq $null) {
    Write-Host "El equipo no está conectado a una red Wi-Fi." -ForegroundColor Yellow
    return
}

# Carpeta donde se encuentra el script
$scriptFolder = Split-Path -Path $MyInvocation.MyCommand.Path

# Cambiar el nombre del archivo de salida aquí:
$nombre_archivo = "pass_wifi.txt"

# Ruta completa del archivo de salida
$ruta_archivo = Join-Path -Path $scriptFolder -ChildPath $nombre_archivo

# Ejecutar el comando netsh para obtener las contraseñas y guardarlas en una variable
$contrasenas_wifi = netsh wlan show profile | Select-String "\bTodos los usuarios\b|\bUsuario actual\b" | %{(netsh wlan show profile name=$_.matches[0].value key=clear)}

# Verificar si el archivo de salida ya existe y pedir confirmación antes de sobrescribirlo
if (Test-Path -Path $ruta_archivo) {
    $confirm = Read-Host "El archivo $nombre_archivo ya existe en la carpeta $scriptFolder. ¿Desea sobrescribirlo? (S/N)"
    if ($confirm -ne 'S') {
        Write-Host "Operación cancelada." -ForegroundColor Yellow
        return
    }
}

# Escribir las contraseñas en el archivo de salida
try {
    Set-Content -Path $ruta_archivo -Value $contrasenas_wifi
    Write-Host "Contraseñas guardadas exitosamente en $ruta_archivo"
} catch {
    Write-Host "Error al escribir en el archivo: $_.Exception.Message"
}
