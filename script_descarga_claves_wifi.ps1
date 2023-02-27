$url = "https://raw.githubusercontent.com/Cedaleon/wifi-password.ps1/main/wifi-password.ps1"
$archivo = "claves_wifi.txt"
Invoke-WebRequest -Uri $url -OutFile wifi-password.ps1
.\wifi-password.ps1 | Out-File -FilePath $archivo

