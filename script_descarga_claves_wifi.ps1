import subprocess

# Ejecuta el comando para obtener perfiles de Wi-Fi
result = subprocess.run(["netsh", "wlan", "show", "profiles"], capture_output=True, text=True)

# Obtener nombres de perfil de Wi-Fi
profiles = [i.split(":")[1][1:-1] for i in result.stdout.splitlines() if "Todos los perfiles de usuario" not in i]

# Crear archivo txt para escribir resultados
with open("wifi-passwords.txt", "w") as file:
    for profile in profiles:
        # Obtener información de la red Wi-Fi
        profile_info = subprocess.run(["netsh", "wlan", "show", "profile", profile, "key=clear"], capture_output=True, text=True)
        # Obtener nombre de la red Wi-Fi
        name = [line.split(":")[1][1:-1] for line in profile_info.stdout.splitlines() if "Nombre             :" in line][0]
        # Obtener contraseña de la red Wi-Fi
        try:
            key = [line.split(":")[1][1:-1] for line in profile_info.stdout.splitlines() if "Contenido de la clave" in line][0]
        except IndexError:
            key = "No se pudo encontrar la contraseña"
        
        # Escribir nombre y contraseña de la red Wi-Fi en el archivo txt
        file.write(f"Red Wi-Fi: {name}\nContraseña: {key}\n\n")

# Imprimir mensaje de éxito
print("Se han guardado las contraseñas de las redes Wi-Fi en el archivo wifi-passwords.txt")

