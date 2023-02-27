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

# Obtener el nombre de la red a la que está conectado el equipo
$networkName = (netsh wlan show interfaces | Select-String "Nombre de perfil" | ForEach-Object { $_.ToString().Split(":")[1].Trim() })

# Verificar si el equipo está conectado a una red Wi-Fi
if (-not $networkName) {
    Write-Host "El equipo no está conectado a una red Wi-Fi." -ForegroundColor Yellow
    return
}

# Ejecutar el comando netsh para obtener la contraseña de la red actual y guardarla en una variable
$contrasena_wifi = netsh wlan show profile name=$networkName key=clear | Select-String "Contenido de la clave" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }

# Verificar si se encontró la contraseña de la red actual y escribirla en el archivo de salida
if (-not $contrasena_wifi) {
    Write-Host "No se pudo encontrar la contraseña de la red Wi-Fi actual." -ForegroundColor Yellow
    return
} else {
    try {
        Set-Content -Path $ruta_archivo -Value $contrasena_wifi
        Write-Host "Contraseña guardada exitosamente en $ruta_archivo"
    } catch {
        Write-Host "Error al escribir en el archivo: $_.Exception.Message"
    }
}
