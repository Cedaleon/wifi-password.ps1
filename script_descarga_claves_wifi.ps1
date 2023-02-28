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
    $contrasena_red = (netsh wlan show profile name="$nombre_red" key=clear) -replace "(?ms).*Clave de seguridad.*:\s*(.*)\s*\n.*", '$1'
    if ($contrasena_red) {
        "${nombre_red}: ${contrasena_red}"
    }
}

# Obtener el nombre de la red a la que se está conectado actualmente
$red_actual = (netsh wlan show interfaces) -match "Nombre de SSID" | Out-String
$red_actual = $red_actual -replace ".*:\s*(.*)", '$1'

# Agregar la contraseña de la red actual a la lista de contraseñas
$contrasenas_wifi += "Red actual: " + (netsh wlan show profile name="$red_actual" key=clear) -replace "(?ms).*Clave de seguridad.*:\s*(.*)\s*\n.*", '$1'

# Ordenar la lista de contraseñas alfabéticamente
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

# Escri
