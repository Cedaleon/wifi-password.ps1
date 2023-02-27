$url = "https://raw.github.com/Cedaleon/wifi-password.ps1/new/main
$archivo = "claves_wifi.txt"
Invoke-WebRequest -Uri $url -OutFile wifi-password.ps1
.\wifi-password.ps1 | Out-File -FilePath $archivo
