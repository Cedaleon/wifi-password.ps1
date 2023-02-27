# Verifica si el equipo está conectado a una red Wi-Fi
$connected = netsh wlan show interfaces | Select-String "Conectado"
if ($connected -eq $null) {
    Write-Host "El equipo no está conectado a una red Wi-Fi." -ForegroundColor Red
    return
}

# Verifica la versión de PowerShell y que se está ejecutando en un equipo con Windows
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "Este script requiere PowerShell 3.0 o posterior." -ForegroundColor Red
    return
}

if (-not (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion")) {
    Write-Host "Este script solo se puede ejecutar en un equipo con Windows." -ForegroundColor Red
    return
}

# Carpeta donde se encuentra el script
$scriptFolder = Split-Path -Path $MyInvocation.MyCommand.Path

# Cambiar el nombre del archivo de salida aquí:
$nombre_archivo = "pass_wifi.txt"

# Ruta completa del archivo de salida
$ruta_archivo = Join-Path -Path $scriptFolder -ChildPath $nombre_archivo

# Ejecutar el comando netsh para obtener la información de la red Wi-Fi actual
$interface = netsh wlan show interfaces | Select-String "Nombre de perfil" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
$profile = netsh wlan show profile name=$interface keyMaterial=clear | Select-String "Contenido de la clave" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }

# Verificar si el archivo de salida ya existe y pedir confirmación antes de sobrescribirlo
if (Test-Path -Path $ruta_archivo) {
    $confirm = Read-Host "El archivo $nombre_archivo ya existe en la carpeta $scriptFolder. ¿Desea sobrescribirlo? (S/N)"
    if ($confirm -ne 'S') {
        Write-Host "Operación cancelada." -ForegroundColor Yellow
        return
    }
}

# Escribir la información de la red Wi-Fi actual en el archivo de salida
try {
    Set-Content -Path $ruta_archivo -Value $profile
    Write-Host "Contraseña de la red Wi-Fi actual guardada exitosamente en $ruta_archivo"
} catch {
    Write-Host "Error al escribir en el archivo: $_.Exception.Message"
}
