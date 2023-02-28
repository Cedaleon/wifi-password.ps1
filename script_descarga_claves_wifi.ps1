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

# Ejecutar el comando netsh para obtener las contraseñas y guardarlas en una variable
$redes_wifi = netsh wlan show profile
$contrasenas_wifi = foreach ($red in $redes_wifi) {
    $nombre_red = $red -replace ".*:\s*(.*)", '$1'
    $contrasena_red = (netsh wlan show profile name="$nombre_red" key=clear) -replace "(?ms).*Clave de seguridad.*:\s*(.*?)\s*\n.*", '$1'
    if ($contrasena_red) {
        "${nombre_red}: ${contrasena_red}"
    }
}

# Ordenar las contraseñas alfabéticamente por nombre de red
$contrasenas_wifi = $contrasenas_wifi | Sort-Object

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

# Escribir las contraseñas ordenadas en el archivo de salida
try {
    $contrasenas_wifi | Format-Table -Property @{Label="Red";Expression={$_.Split(":")[0]}},@{Label="Contraseña";Expression={$_.Split(":")[1]}} | Out-File -FilePath $nombre_archivo -Encoding utf8 -Append
    Write-Host "Contraseñas guardadas exitosamente en $nombre_archivo"
} catch {
    Write-Host "Error al escribir en el archivo: $($_.Exception.Message)" -ForegroundColor Red
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
