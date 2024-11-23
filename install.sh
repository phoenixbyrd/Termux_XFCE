#!/bin/bash

# Modo estricto no oficial de Bash
set -euo pipefail
IFS=$'\n\t'

# Función para manejar errores y mensajes al finalizar
finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    echo "ERROR: Falló la configuración de XFCE en Termux."
    echo "Por favor, revisa los mensajes de error anteriores."
  fi
}

trap finish EXIT

# Limpiar la pantalla
clear

echo ""
echo "Este script instalará el escritorio XFCE en Termux junto con un proot de Debian."
echo ""
# Configurar el nombre de usuario automáticamente como "ubuntu"
username="ubuntu"
echo "El nombre de usuario para la instalación de proot será: $username"

# Cambiar el repositorio de Termux
termux-change-repo

# Actualizar y mejorar paquetes en Termux
pkg update -y -o Dpkg::Options::="--force-confold"
pkg upgrade -y -o Dpkg::Options::="--force-confold"
sed -i '12s/^#//' $HOME/.termux/termux.properties

# Mostrar mensaje y configurar acceso al almacenamiento de Termux
clear -x
echo ""
echo "Configurando acceso al almacenamiento de Termux." 
echo ""
read -n 1 -s -r -p "Presiona cualquier tecla para continuar..."
termux-setup-storage

# Lista de paquetes necesarios
pkgs=('wget' 'ncurses-utils' 'dbus' 'proot-distro' 'x11-repo' 'tur-repo' 'pulseaudio')

# Desinstalar e instalar paquetes necesarios
pkg uninstall dbus -y
pkg update
pkg install "${pkgs[@]}" -y -o Dpkg::Options::="--force-confold"

# Crear directorios predeterminados
mkdir -p Desktop
mkdir -p Downloads

# Descargar los scripts necesarios
wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/xfce.sh
wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/proot.sh
wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/utils.sh
chmod +x *.sh

# Ejecutar los scripts descargados
./xfce.sh "$username"
./proot.sh "$username"
./utils.sh

# Instalar la aplicación Termux-X11 APK
clear -x
echo ""
echo "Instalando la APK de Termux-X11" 
echo ""
read -n 1 -s -r -p "Presiona cualquier tecla para continuar..."
wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk

# Recargar configuraciones de Termux
source $PREFIX/etc/bash.bashrc
termux-reload-settings

# Mensaje de éxito
clear -x
echo ""
echo "¡La configuración se completó exitosamente!"
echo ""
echo "Para abrir el escritorio utiliza el comando 'start'."
echo ""
echo "Esto iniciará el servidor termux-x11, el escritorio XFCE y abrirá la aplicación Termux-X11 instalada."
echo ""
echo "Para salir, haz doble clic en el icono 'Kill Termux X11' en el panel."
echo ""
echo "¡Disfruta de tu experiencia con el escritorio XFCE4 en Termux!"
echo ""

# Eliminar scripts usados para instalación
rm xfce.sh
rm proot.sh
rm utils.sh
rm install.sh
