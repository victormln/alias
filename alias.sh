#!/bin/bash
# Filename: alias.sh
# Author: Víctor Molina Ferreira (github.com/victormln)
# Creating date: 12/11/16
# Version: 2.1.4

# Mensajes de color
ERROR='\033[0;31m'
OK='\033[0;32m'
WARNING='\033[1;33m'
NC='\033[0m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
# Get the current version
CURRENTVERSION=$(grep '# Version:' $0 | cut -d: -f 2 | head -1)
CURRENTVERSION=${CURRENTVERSION//[[:blank:]]/}
CURRENTDIR=$(pwd)
INSTALL_ALIASDIRECTORY=$( dirname "${BASH_SOURCE[0]}" )
OSTYPE="Linux"
if [ "$(uname)" == "Darwin" ]; then
  OSTYPE="Darwin"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ] ||
  [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    OSTYPE="Windows"
fi
##########################
# Script code            #
##########################

# Primero cambiamos al directorio del script
cd $( dirname "${BASH_SOURCE[0]}" )

# Importamos las funciones
source functions/functions.sh
# Cogemos los datos del archivo .conf
source user.conf

# Comprobamos que shell tiene el usuario para modificar la variable FILE_WITH_ALIAS
checkShell

# Cogemos las variables de idioma
source lang/${LANGUAGE}.lang

# Comprobamos primero si ha ejecutado el restaurar la copia de seguridad
if [ "$1" == "--restore" ]
then
  parseOption $1
  exit
fi

if [ "$1" == "-v" ]
then
  echo $CURRENTVERSION
  exit 0
fi

if ! [ -e ${FILE_WITH_ALIAS} ]
then
  echo "$ALIAS_FILE_NOT_FOUND"
  echo "$ROUTE_ALIAS_FILE_MESSAGE"
  exit 1
fi

if $SHOW_AUTHOR; then echo "$AUTHOR: Víctor Molina <github.com/victormln> "; fi;

# Doy permiso al update.sh
chmod +x update.sh

if [ "$1" == "--update" ]
then
	echo -e "$FORCE_UPDATE_MESSAGE"
elif [ "$1" == "--conf" ]
then
	echo -e "$OPENING_CONFIGURATION_MESSAGE"
    $DEFAULT_EDITOR user.conf
fi

# Comprobaré si hay alguna versión nueva del programa autopush
# y lo mostraré en pantalla
source update.sh

# Primero compruebo que el archivo tenga alias dentro
if cat ${FILE_WITH_ALIAS} | grep "^alias " > /dev/null
then
  # Iniciamos el script
  if ! [ -z $1 ]
  then
  	parseOption $@
  else
    parseOption
  fi
  exit
else
  echo -e "$FILE_DOES_NOT_CONTAIN_ALIAS"
  echo -e "$CANNOT_USE_OPTIONS"
  echo "$REMEMBER_FILE_ALIAS"
  echo "$RESTORE_HELP_MESSAGE"
  parseOption
fi
