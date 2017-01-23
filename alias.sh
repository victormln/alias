#!/bin/bash
# Fichero: alias.sh
# Autor: Víctor Molina Ferreira (www.victormln.es)
# Fecha: 12/11/16
# Versión: 1.0

# Mensajes de color
ERROR='\033[0;31m'
OK='\033[0;32m'
WARNING='\033[1;33m'
NC='\033[0m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'

function aliasAdded {
  #Mostramos mensaje conforme se han creado los alias y se ha salido del programa
  echo -e $ALIASCREATED
}

function add {
  echo -e ${WARNNEWALIAS}
	continuar="y"
	# Preguntamos hasta que el usuario quiera, si quiere crear alias
	while confirmYes $continuar
	do
    name=$1
    if [ -z $1 ]
    then
      echo -e "$INSERTNAMEOFALIAS:"
      read name
    fi
    if cat ${FILE_WITH_ALIAS} | grep "^alias $name=" > /dev/null
    then
      echo -e "$ERRORALIASEXISTS"
      nombreErroneo=1
      while cat ${FILE_WITH_ALIAS} | grep "^alias $name=" > /dev/null
      do
        echo -e "$CHOOSEANOTHERNAME"
        read name
      done
      if [ $name == "q" ] || [ $name == "Q" ]
      then
        exit
      else
        echo -e "$INSERTCOMMAND ${ORANGE}$name${NC}:"
        read alias_command
        #Añadimos al .bashrc el alias
        echo alias $name=\"$alias_command\" >> ${FILE_WITH_ALIAS}
        aliasAdded
        echo -e "$ASKCREATEANOTHERALIAS $OPTIONSCONFIRM"
        read continuar
      fi
    else
      echo -e "$INSERTCOMMAND ${ORANGE}$name${NC}:"
      read alias_command
      #Añadimos al .bashrc el alias
      echo alias $name=\"$alias_command\" >> ${FILE_WITH_ALIAS}
      aliasAdded
      echo "$ASKCREATEANOTHERALIAS $OPTIONSCONFIRM"
      read continuar
    fi
	done
}

function show {
  echo "$SHOWALIASCREATED"
  echo "*---------------------------------------------------*"
  # Meto todos los alias en un archivo temporal y los muestro
  cat ${FILE_WITH_ALIAS} | grep -E "^alias " > .alias.tmp
  while read linea
  do
    nombreScript=$(echo "$linea" | cut -d"=" -f 1)
    comando=$(echo "$linea" | cut -d"=" -f 2)
    # Elimino la palabra alias para que solo se vea lo que importa
    echo -e " ${ORANGE}$nombreScript${NC}=$comando" | sed 's/alias //g'
    contador=$(($contador + 1))
  done < .alias.tmp
  rm .alias.tmp
  echo "*---------------------------------------------------*"
  echo "$OPTIONSSCRIPT"
  exit
}

function edit {
  # Meto todos los alias en un archivo temporal y los muestro
  cat ${FILE_WITH_ALIAS} | grep -E "^alias " > .alias.tmp
  # En el caso de que el usuario no le haya pasado un argumento,
  # significa que no sabe cual va a editar
  if [ -z $1 ]
  then
    showAlias
    echo "$SELECTALIAS"
    read selectedOption
    if [[ "$selectedOption" =~ ^[0-9]+$ ]]
    then
      nombre=$(sed "$selectedOption!d" .alias.tmp | cut -d"=" -f 1 | cut -d" " -f 2)
      comando=$(sed "$selectedOption!d" .alias.tmp | cut -d"=" -f 2)
      editSpecificAlias $nombre $comando
    else
      editSpecificAlias $selectedOption
    fi
    rm .alias.tmp
  # En el caso que le haya pasado un argumento (el nombre de un alias)
  # podrá modificarlo, sino le muestra que ese nombre de alias, no existe
  else
    # Compruebo si el alias que ha pasado el usuario existe
    if cat .alias.tmp | grep "^alias $1=" > /dev/null
    then
      editSpecificAlias $1
    else
      # Si no existe el alias que el usuario ha pasado por argumento
      # ejecuto otra vez la funcion edit para que seleccione un alias que exista
      echo -e "$ALIASNOTEXISTS ${ORANGE}$1${NC}"
      edit
    fi
  fi
}

# A esta funcion le paso un argumento, que será el nombre del alias a editar
function editSpecificAlias {
  commando=$(cat .alias.tmp | grep -E "alias $1=$2" | cut -d"=" -f 2 | head -1)
  # Elimino las comillas del sufijo
  temp="${commando%\"}"
  # Elimino las comillas del prefijo
  commando="${temp#\"}"
  echo -e "$ALIASSELECTED ${ORANGE}$1${NC}"
  echo "$INSERTNAMEOFALIAS:"
  read -e -i $1 name
  echo -e "$INSERTCOMMAND ${ORANGE}$name${NC}:"
  read -e -i $commando alias_command
  #echo $alias_command
  # Antes de nada, le hacemos una copia al usuario de su bashrc
  cp ${FILE_WITH_ALIAS} ${DIR_BACKUP}.alias_backup.txt
  # Miramos si tiene o no comillas el alias antiguo
  if cat ${FILE_WITH_ALIAS} | grep "^alias $1=\"$commando\"" &> /dev/null
  then
    # la coma es el delimitador para el sed
    sed "s,^alias $1=\"$commando\",alias $name=\"$alias_command\",g" ${FILE_WITH_ALIAS} > ~/bash.txt
  else
    # la coma es el delimitador para el sed
    sed "s,^alias $1=$commando,alias $name=\"$alias_command\",g" ${FILE_WITH_ALIAS} > ~/bash.txt
  fi
  # Eliminamos
  rm ${FILE_WITH_ALIAS}
  mv ~/bash.txt ${FILE_WITH_ALIAS}
  if [ $? -eq 0 ]
  then
    echo -e "$MODIFIEDDONE"
  else
    echo -e "$UNKNOWNPROBLEM"
  fi
}

function delete {
  # Meto todos los alias en un archivo temporal y los muestro
  cat ${FILE_WITH_ALIAS} | grep -E "^alias " > .alias.tmp
  # En el caso de que el usuario no le haya pasado un argumento,
  # significa que no sabe cual va a editar
  if [ -z $1 ]
  then
    showAlias
    echo "$NAMEALIASDELETE"
    read selectedOption
    if [[ "$selectedOption" =~ ^[0-9]+$ ]]
    then
      nombre=$(sed "$selectedOption!d" .alias.tmp | cut -d"=" -f 1 | cut -d" " -f 2)
      deleteSpecificAlias $nombre
    else
      deleteSpecificAlias $selectedOption
    fi
    rm .alias.tmp
  # En el caso que le haya pasado un argumento (el nombre de un alias)
  # podrá modificarlo, sino le muestra que ese nombre de alias, no existe
  else
    for param in "$@"
    do
      # Compruebo si el alias que ha pasado el usuario existe
      if cat .alias.tmp | grep "^alias $param=" > /dev/null
      then
        deleteSpecificAlias $param
      else
        # Si no existe el alias que el usuario ha pasado por argumento
        # ejecuto otra vez la funcion delete para que seleccione un alias que exista
        echo -e "$ALIASNOTEXISTS ${ORANGE}$param${NC}"
        delete
      fi
    done
  fi
}

function deleteSpecificAlias {
  comando=$(cat .alias.tmp | grep -E "alias $1=" | cut -d"=" -f 2 | head -1)
  # Elimino las comillas del sufijo
  temp="${commando%\"}"
  # Elimino las comillas del prefijo
  comando="${temp#\"}"
  echo -e "$CONFIRMDELETE ${ORANGE}$1${NC}?"
  read confirmation
  if ! confirmYes $confirmation
  then
    exit -1
  fi
  # Antes de nada, le hacemos una copia al usuario de su bashrc
  cp ${FILE_WITH_ALIAS} ${DIR_BACKUP}.alias_backup.txt
  # la coma es el delimitador para el sed
  # El 0 es para que solo elimine la primera ocurrencia
  sed "1!{/^alias $1=/d;}" ${FILE_WITH_ALIAS} > ~/bash.txt
  #sed "0,/^alias $1=\"$commando\"/{/^alias $1=\"$commando\"/d;}" ${FILE_WITH_ALIAS} > ~/bash.txt
  #sed "0,/^alias $1=\"$commando\"/ d" ${FILE_WITH_ALIAS} > ~/bash.txt
  #sed "s,^alias $1=\"$commando\",,g" ${FILE_WITH_ALIAS} > ~/bash.txt
  # Eliminamos
  rm ${FILE_WITH_ALIAS}
  mv ~/bash.txt ${FILE_WITH_ALIAS}
  if [ $? -eq 0 ]
  then
    echo -e "$DELETEDONE"
  else
    echo -e "$UNKNOWNPROBLEM"
  fi
}

function empty {
  numberEmptyLines=$(grep -cvP '\S' ${FILE_WITH_ALIAS})
  numberEmptyAlias=$(grep '^alias .*=\"\"$' ${FILE_WITH_ALIAS} | wc -l)
  numberEmptyAliasWithoutQuotes=$(grep '^alias .*=$' ${FILE_WITH_ALIAS} | wc -l)
  numberEmptyAlias=$(($numberEmptyAlias + $numberEmptyAliasWithoutQuotes))
  if [ $numberEmptyLines != 0 ]
  then
    echo "$MESSAGEEMPTYLINES"
    echo "$DELETEEMPTYLINES"
    read delete
    if confirmYes $delete
    then
      sed -i '/^\s*$/d' ${FILE_WITH_ALIAS}
      echo -e "$EMPTYLINESDELETED"
    fi
  else
    echo -e "$NOEMPTYLINES"
  fi
  # Comprobamos si tiene alias en blanco
  if ! [ $numberEmptyAlias -eq 0 ]
  then
    echo "$EMPTYALIAS"
    echo "$DELETEEMPTYALIAS"
    read delete
    if confirmYes $delete
    then
      sed -i '/^alias .*=\"\"*$/d' ${FILE_WITH_ALIAS}
      sed -i '/^alias .*=$/d' ${FILE_WITH_ALIAS}
      echo -e "$EMPTYALIASDELETED"
    fi
  else
    echo -e "$NOEMPTYALIAS"
  fi


}

function copy {
  # Meto todos los alias en un archivo temporal y los muestro
  cat ${FILE_WITH_ALIAS} | grep -E "^alias " > .alias.tmp
  # En el caso de que el usuario no le haya pasado un argumento,
  # significa que no sabe cual va a editar
  if [ -z $1 ]
  then
    showAlias
    echo "$SELECTCOPYALIAS"
    read selectedOption
    if [[ "$selectedOption" =~ ^[0-9]+$ ]]
    then
      nombre=$(sed "$selectedOption!d" .alias.tmp | cut -d"=" -f 1 | cut -d" " -f 2)
      copySpecificAlias $nombre
    else
      copySpecificAlias $selectedOption
    fi
    rm .alias.tmp
  # En el caso que le haya pasado un argumento (el nombre de un alias)
  # podrá modificarlo, sino le muestra que ese nombre de alias, no existe
  else
    # Compruebo si el alias que ha pasado el usuario existe
    if cat .alias.tmp | grep "^alias $1=" > /dev/null
    then
      if [ -z $2 ]
      then
        copySpecificAlias $1
      else
        copySpecificAlias $1 $2
      fi
    else
      # Si no existe el alias que el usuario ha pasado por argumento
      # ejecuto otra vez la funcion edit para que seleccione un alias que exista
      echo -e "$ALIASNOTEXISTS ${ORANGE}$1${NC}"
      copy
    fi
  fi
}

function copySpecificAlias {
  commando=$(cat .alias.tmp | grep -E "alias $1=" | cut -d"=" -f 2 | head -1)
  # Elimino las comillas del sufijo
  temp="${commando%\"}"
  # Elimino las comillas del prefijo
  commando="${temp#\"}"
  if [ -z $2 ]
  then
    echo -e "$ALIASSELECTED ${ORANGE}$1${NC}."
    echo "$INSERTNAMEOFALIAS:"
    read name_alias
    echo alias $name_alias=\"$commando\" >> ${FILE_WITH_ALIAS}
    echo -e "$COPIEDDONE ${ORANGE}$name_alias${NC}."
  else
    echo alias $2=\"$commando\" >> ${FILE_WITH_ALIAS}
    if [ $? -eq 0 ]
    then
      echo -e "$COPIEDDONE ${ORANGE}$2${NC}."
    else
      echo -e "$COPYERROR"
    fi
  fi
}

# Le paso como primer argumento la respuesta del usuario (normalmente una s/y/n)
function confirmYes {
  if ! [ -z $1 ]
  then
    if [ $1 == "y" ] || [ $1 == "Y" ] ||
     [ $1 == "s" ] || [ $1 == "S" ]
    then
      return 0
    else
      echo "$MENUSELECTION $1. $EXITSCRIPT."
      return 1
    fi
  else
    echo "$EXITSCRIPTWITHOPTIONS"
    exit -1
  fi
}

function showAlias {
  echo "$SHOWALIASCREATED"
  # Mientras hayan alias, irlos mostrando
  contador=1
  while read linea
  do
    nombreScript=$(echo "$linea" | cut -d"=" -f 1)
    comando=$(echo "$linea" | cut -d"=" -f 2)
    # Elimino la palabra alias para que solo se vea lo que importa
    echo -e "\t${BLUE}[$contador] ${ORANGE}$nombreScript${NC}=$comando" | sed 's/alias //g'
    contador=$(($contador + 1))
  done < .alias.tmp
}

function deleteDuplicateAlias {
  awk "/^alias $1=/&&c++>0 {next} 1" ${FILE_WITH_ALIAS}
}

function restore {
  if ! [ -e ${DIR_BACKUP}.alias_backup.txt ]
  then
    cat ${DIR_BACKUP}.alias_backup.txt
    echo -e "$BACKUPNOTFOUND"
    echo "$ROUTEBACKUPMESSAGE"
  else
    cp ${DIR_BACKUP}.alias_backup.txt ${FILE_WITH_ALIAS}
    echo -e "$BACKUPDONE"
  fi
}

function showHelp {
	echo -e "$USAGEMESSAGE"

  echo -e "$ADDHELPUSAGE"
  echo -e "$EDITHELPUSAGE"
  echo -e "$LISTHELPUSAGE"

  echo -e "$DELETEHELPUSAGE"

  echo -e "$COPYHELPUSAGE"
  echo -e "$RESTOREHELPMESSAGE"
  echo -e "$EMPTYHELPMESSAGE"
}

function parseOption {
  # En el caso de que el usuario no le haya pasado un argumento,
  # por defecto significa que quiere crear un alias
  if [ -z $1 ]
  then
    add
  else
    # Miramos que ha seleccionado el usuario (add, edit, delete, help, show)
    if [ $1 == "add" ] || [ $1 == "-a" ]
  	then
      if [ -z $2 ]
      then
  		    add
      else
          add $2
      fi
  	elif [ $1 == "edit" ] || [ $1 == "-e" ]
  	then
      # Si no le pasa un segundo argumento a edit (el nombre del alias)
      # le preguntaremos en el edit cual quiere modificar
      if [ -z $2 ]
      then
        edit
      else
        edit $2
      fi
  	elif [ $1 == "delete" ] || [ $1 == "-d" ]
  	then
        # Si no le pasa un segundo argumento a delete (el nombre del alias)
        # le preguntaremos en el delete cual quiere eliminarsss
        if [ -z $2 ]
        then
          delete
        else
          # Recorro un argumento ya que sino, le pasaria también
          # el -d o el delete (y solo quiero los nombres de los alias)
          shift
          delete $@
        fi
    elif [ $1 == "copy" ] || [ $1 == "-cp" ]
    then
      if [ -z $2 ]
      then
        copy
      elif [ -z $3 ]
      then
        copy $2
      else
        copy $2 $3
      fi
  	elif [ $1 == "-h" ] || [ $1 == "--help" ]
  	then
  		showHelp
    elif [ $1 == "show" ] || [ $1 == "view" ] || [ $1 == "list" ] || [ $1 == "-l" ]
    then
      show
    elif [ $1 == "--empty" ]
    then
      empty
    elif [ $1 == "--restore" ]
    then
      restore
    else
      # Cualquier otro parámetro, mostramos la ayuda
      showHelp
  	fi
  fi
}


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

if ! [ -e ${FILE_WITH_ALIAS} ]
then
  echo "$ALIASFILENOTFOUND"
  echo "$ROUTEALIASFILEMESSAGE"
  exit 1
fi

echo "Alias Manager v$version"
if $show_author; then echo "$AUTHORMESSAGE: Víctor Molina [victormln.com] <contact@victormln.com> "; fi;

# Doy permiso al update.sh
chmod +x update.sh
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
