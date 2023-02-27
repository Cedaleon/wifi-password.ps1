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

# Obtener el nombre del perfil de la red Wi-Fi conectada
$perfil = (netsh wlan show interfaces | Select-String "Perfil de todos los usuarios" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }).ToString()

# Obtener la contraseña del perfil de la red Wi-Fi conectada
$contrasena = (netsh wlan show profile name=$perfil key=clear | Select-String "Contenido de la clave" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }).ToString()

# Solicitar el nombre de la red al usuario
$nombre_red = Read-Host "Ingrese el nombre de la red Wi-Fi"

# Verificar si el archivo de salida ya existe y pedir confirmación antes de sobrescribirlo
$ruta_archivo = Join-Path -Path $scriptFolder -ChildPath "pass_wifi.txt"
if (Test-Path -Path $ruta_archivo) {
    $confirm = Read-Host "El archivo pass_wifi.txt ya existe en la carpeta $scriptFolder. ¿Desea sobrescribirlo? (S/N)"
    if ($confirm -ne 'S') {
        Write-Host "Operación cancelada." -ForegroundColor Yellow
        return
    }
}

# Escribir el nombre de la red y la contraseña en el archivo de salida
try {
    Set-Content -Path $ruta_archivo -Value "$nombre_red:`n$contrasena"
    Write-Host "Contraseña guardada exitosamente en $ruta_archivo"
} catch {
    Write-Host "Error al escribir en el archivo: $_.Exception.Message"
}
