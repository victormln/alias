#!/bin/bash
# Hace una instalación del script

# Mensajes de color
ERROR='\033[0;31m'
BLUE='\033[0;34m'
OK='\033[0;32m'
NC='\033[0m'

# Creo un alias para que se pueda ejecutar el script
actualDir=$(pwd)
actualShell=$(echo $SHELL | grep zsh)
if [ $? -eq 0 ]
then
    actualShell="zshrc"
    ABBREVIATION_SHELL="zsh"
else
    actualShell="bashrc"
    ABBREVIATION_SHELL="bash"
fi
chmod +x alias.sh
echo "alias malias=\"$actualDir/alias.sh\"" >> ~/.$actualShell
echo -e "${OK}[OK]${NC} Instalación finalizada."
echo -e "Ahora tiene que ejecutar: "${BLUE}source ~/.$actualShell${NC}" y después ya podrá usar malias.Para comprobar que se ha instalado correctamente use: ${BLUE}malias -v${NC}."
exit
