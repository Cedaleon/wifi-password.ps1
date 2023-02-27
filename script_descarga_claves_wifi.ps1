Verifica la versión de PowerShell y que se está ejecutando en un equipo con Windows
if ($PSVersionTable.PSVersion.Major -lt 3) {
Write-Host "Este script requiere PowerShell 3.0 o posterior." -ForegroundColor Red
return
}

if (-not (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion")) {
Write-Host "Este script solo se puede ejecutar en un equipo con Windows." -ForegroundColor Red
return
}

Cambiar el nombre del archivo de salida aquí:
$nombre_archivo = "pass_wifi.txt"

Ejecutar el comando netsh para obtener las contraseñas y guardarlas en una variable
$contrasenas_wifi = netsh wlan show profile | Select-String "\bTodos los usuarios\b|\bUsuario actual\b" | %{(netsh wlan show profile name=$.matches[0].value key=clear)}
$contrasenas_wifi = $contrasenas_wifi | Select-String "SSID name|Key Content" | %{($ -split ":\s+")[1]}

Verificar si el archivo de salida ya existe y pedir confirmación antes de sobrescribirlo
if (Test-Path -Path $nombre_archivo) {
$confirm = Read-Host "El archivo $nombre_archivo ya existe. ¿Desea sobrescribirlo? (S/N)"
if ($confirm -ne 'S') {
Write-Host "Operación cancelada." -ForegroundColor Yellow
return
} else {
Remove-Item -Path $nombre_archivo -ErrorAction SilentlyContinue
}
}

Escribir las contraseñas en el archivo de salida
try {
$contrasenas_wifi | Out-File -FilePath $nombre_archivo -Encoding utf8 -Append
Write-Host "Contraseñas guardadas exitosamente en $nombre_archivo"
} catch {
Write-Host "Error al escribir en el archivo: $_.Exception.Message"
}
