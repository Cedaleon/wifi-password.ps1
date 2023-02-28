# Verifica la versión de PowerShell y que se está ejecutando en un equipo con Windows
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Host "Este script requiere PowerShell 3.0 o posterior." -ForegroundColor Red
    return
}

if (-not (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion")) {
    Write-Host "Este script solo se puede ejecutar en un equipo con Windows." -ForegroundColor Red
    return
}

# Cambiar el nombre del archivo de salida aquí:
$nombre_archivo = "pass_wifi.txt"

# Verificar que esté conectado a una red WiFi
if ((Get-NetConnectionProfile).Name -eq "No hay ninguna conexión") {
    Write-Host "No estás conectado a ninguna red WiFi. Conéctate a una red WiFi antes de ejecutar este script." -ForegroundColor Red
    return
}

# Obtener el nombre de la red WiFi actual
$nombre_red = (Get-NetConnectionProfile).Name

# Ejecutar el comando netsh para obtener la contraseña de la red WiFi actual y guardarla en una variable
$contrasena_wifi = netsh wlan show profile name=$nombre_red key=clear | Select-String "Contenido de la clave"

# Verificar si el archivo de salida ya existe y pedir confirmación antes de sobrescribirlo
if (Test-Path -Path $nombre_archivo) {
    $confirm = Read-Host "El archivo $nombre_archivo ya existe. ¿Desea sobrescribirlo? (S/N)"
    if ($confirm -ne 'S') {
        Write-Host "Operación cancelada." -ForegroundColor Yellow
        return
    } else {
        Remove-Item -Path $nombre_archivo -ErrorAction SilentlyContinue
    }
}

# Escribir la contraseña en el archivo de salida
try {
    $contrasena_wifi | Out-File -FilePath $nombre_archivo -Encoding utf8 -Append
    Write-Host "Contraseña de la red WiFi guardada exitosamente en $nombre_archivo"
} catch {
    Write-Host "Error al escribir en el archivo: $_.Exception.Message"
}

# Agregar la recomendación de cambiar los permisos del archivo para evitar acceso no autorizado
$archivo = Get-Item $nombre_archivo
if ($archivo) {
    $acl = Get-Acl $nombre_archivo
    $ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Usuarios","ReadAndExecute","Allow")
    $acl.SetAccessRule($ar)
    Set-Acl $nombre_archivo $acl
    Write-Host "Se han actualizado los permisos de $nombre_archivo para evitar acceso no autorizado."
}

