#!/bin/bash
# Fichero: alias.sh
# Autor: Víctor Molina Ferreira (www.victormln.es)
# Fecha: 12/11/16
# Versión: 2.0.1

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
CURRENTVERSION=$(grep '# Versión:' $0 | cut -d: -f 2 | head -1)
CURRENTVERSION=${CURRENTVERSION//[[:blank:]]/}

##########################
# Aquí empieza el script #
##########################
# Pendiente
# Poder hacer edit pasandole 2 argumentos
# Copiar el sed del edit para el delete
# Sugerencia, buscar comando para eliminar todas las ocurrencias menos la primera
# para eliminar todos los alias repetidos menos el primero

# Primero cambiamos al directorio del script
cd $( dirname "${BASH_SOURCE[0]}" )

# Importamos las funciones
source functions/functions.sh
# Cogemos los datos del archivo .conf
source user.conf
# Cogemos las variables de idioma
source lang/${LANGUAGE}.po

# Comprobamos primero si ha ejecutado el restaurar la copia de seguridads
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
  echo "$ALIASFILENOTFOUND"
  echo "$ROUTEALIASFILEMESSAGE"
  exit 1
fi

echo "Alias Manager v$CURRENTVERSION"
if $show_author; then echo "$AUTHORMESSAGE: Víctor Molina [victormln.com] <contact@victormln.com> "; fi;

# Doy permiso al update.sh
chmod +x update.sh

if [ "$1" == "--update" ]
then
	echo -e "$FORCEUPDATE"
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
  	exit
  else
    parseOption
  fi
else
  echo -e "$FILENOTCONTAINALIAS"
  echo -e "$CANNOTUSEOPTIONS"
  echo "$REMEMBERFILEALIAS"
  echo "$RESTOREHELPMESSAGE"
  parseOption
fi
