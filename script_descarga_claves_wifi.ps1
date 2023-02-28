# Verificar la versión de PowerShell y que se está ejecutando en un equipo con Windows
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Error "Este script requiere PowerShell 3.0 o posterior para funcionar correctamente."
    return
}

if (-not (Test-OperatingSystem Windows)) {
    Write-Error "Este script solo se puede ejecutar en un equipo con Windows."
    return
}

# Cambiar el nombre del archivo de salida aquí:
$nombre_archivo = "pass_wifi.txt"

# Ejecutar el comando netsh para obtener las contraseñas y guardarlas en una variable
$redes_wifi = netsh wlan show profile
$contrasenas_wifi = foreach ($red in $redes_wifi) {
    $nombre_red = $red -replace ".*:\s*(.*)", '$1'
    $contrasena_red = (netsh wlan show profile name="$nombre_red" key=clear) -replace "(?ms).*Clave de seguridad.*:\s*(.*)\s*\n
