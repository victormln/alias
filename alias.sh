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
  echo -e "${OK}[OK]${NC} Alias creado!"
}

function add {
  echo -e "${WARNING}Se va a crear un alias nuevo.${NC}"
	continuar="y"
	# Preguntamos hasta que el usuario quiera, si quiere crear alias
	while [ $continuar == "y" ] || [ $continuar == "Y" ] ||
   [ $continuar == "s" ] || [ $continuar == "S" ]
	do
    echo -e "Introduce un nombre para el alias:"
    read name
    echo -e "Introduce ahora el comando que querrás ejecutar con el alias ${ORANGE}$name${NC} (no hace falta que pongas las comillas):"
    read alias_command
    #Añadimos al .bashrc el alias
    echo alias $name=\"$alias_command\" >> ${FILE_WITH_ALIAS}
    aliasAdded
    echo "Quieres crear otro alias? Escribe: [y / n] o [s / n] para continuar."
    read continuar
	done
}

function show {
  echo "Estos son los alias que tienes creados hasta ahora:"
  echo "*---------------------------------------------------*"
  # Meto todos los alias en un archivo temporal y los muestro
  cat ${FILE_WITH_ALIAS} | grep -E "^alias " > .alias.tmp
  while read linea
  do
    nombreScript=$(echo "$linea" | cut -d"=" -f 1)
    comando=$(echo "$linea" | cut -d"=" -f 2)
    # Elimino la palabra alias para que solo se vea lo que importa
    echo -e "${ORANGE}$nombreScript${NC}=$comando" | sed 's/alias //g'
    contador=$(($contador + 1))
  done < .alias.tmp
  rm .alias.tmp
  echo "*---------------------------------------------------*"
  echo "Recuerda que si quieres editar o eliminar algún alias, puedes ejecutar el script con los argumentos [edit nombre_alias] o [delete]."
  exit
}

function edit {
  # Meto todos los alias en un archivo temporal y los muestro
  cat ${FILE_WITH_ALIAS} | grep -E "^alias " > .alias.tmp
  # En el caso de que el usuario no le haya pasado un argumento,
  # significa que no sabe cual va a editar
  if [ -z $1 ]
  then
    echo "Mostrando todos los alias que tienes:"
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
    #
    echo "Seleccione el número o nombre del alias que quiere editar"
    read selectedOption
    if [[ "$selectedOption" =~ ^[0-9]+$ ]]
    then
      echo "numero"
    else
      echo "**********"
      cat .alias.tmp
      commando=$(cat .alias.tmp | grep -E "alias $selectedOption=" | cut -d"\"" -f 2)
      echo "**********"
      echo $commando
      echo -e "Has seleccionado el alias ${ORANGE}$selectedOption${NC}."
      editSpecificAlias $selectedOption
    fi
    rm .alias.tmp
  # En el caso que le haya pasado un argumento (el nombre de un alias)
  # podrá modificarlo, sino le muestra que ese nombre de alias, no existe
  else
    if $(cat ${FILE_WITH_ALIAS} | grep -E "^alias $1=")
    then
      editSpecificAlias $1
    else
      echo -e "${ERROR}[ERROR]${NC} El alias ${ORANGE}$1${NC} no existe."
      echo "Introduce uno que exista (recuerda que puedes ejecutar el [edit] sin parámetros o ver los alias con [show] o [view])"
    fi
  fi
}

# A esta funcion le paso un argumento, que será el nombre del alias a editar
function editSpecificAlias {
  echo "Que nombre quieres ponerle?:"
  read name_alias
  echo -e "Que comando quieres que se ejecute con el alias ${ORANGE}$name_alias${NC}?:"
  read alias_command
  echo $selectedOption
  # Antes de nada, le hacemos una copia al usuario de su bashrc
  cp ${FILE_WITH_ALIAS} ${FILE_WITH_ALIAS}_copy_alias_script.txt
  # Sustituimos el comando antiguo, por el nuevo
  # la coma es el delimitador para el sed
  sed "s,^alias $selectedOption=\"$commando\",alias $name_alias=\"$alias_command\",g" ${FILE_WITH_ALIAS} > ~/bash.txt
  # Eliminamos
  rm ${FILE_WITH_ALIAS}
  mv ~/bash.txt ${FILE_WITH_ALIAS}
  if [ $? -eq 0 ]
  then
    echo -e "${OK}[OK]${NC} Se ha modificado el alias correctamente"
  else
    echo -e "${ERROR}[ERROR]${NC}Ha ocurrido un problema. Vuelva a ejecutar el script"
  fi
}

function delete {
  echo "delete"
}

function showHelp {
	echo -e "usage: malias [add] [edit] [list] [delete] - Script que te permite crear, modificar, listar o eliminar alias de tu pc."

  echo -e "\n${CYAN}[-a] [add] [add nombre_alias]${NC}"
  echo -e "\tPodrás añadir un alias."
  echo -e "\tEl nombre de alias quieres añadir, puedes poner [add nombre] y el nombre del alias."

  echo -e "\n${CYAN}[-e] [edit] [edit nombre_alias]${NC}"
  echo -e "\tPodrás modificar un alias que tengas ya creado."
  echo -e "\tSi sabes el nombre del alias, puedes poner [edit nombre]"
  echo -e "\tSi no lo sabes, puedes poner [edit] a secas y te saldrá el listado de alias que tienes."

  echo -e "\n${CYAN}[-l] [view] [show] [list]${NC}"
  echo -e "\tPodrás listar/ver todos los alias que tienes."

  echo -e "\n${CYAN}[-d] [delete] [delete nombre_alias]${NC}"
  echo -e "\tPodrás eliminar un alias."
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
  		add
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
  		delete
  	elif [ $1 == "help" ] || [ $1 == "--help" ]
  	then
  		showHelp
    elif [ $1 == "show" ] || [ $1 == "view" ] || [ $1 == "list" ] || [ $1 == "-l" ]
    then
      show
    else
      # Cualquier otro parámetro, mostramos la ayuda
      showHelp
  	fi
  fi
}

# Cogemos los datos del archivo .conf
source user.conf

echo "Alias Manager v$version"
if $show_author; then echo "Autor: Víctor Molina [victormln.com] <contact@victormln.com> "; fi;
# Si están activadas las actualizaciones automáticas
if $search_ota
then
  # Doy permiso al update.sh
  chmod +x update.sh
  # Comprobaré si hay alguna versión nueva del programa autopush
  # y lo mostraré en pantalla
  source update.sh
  # Si no tiene la ultima version y ha actualizado, volvemos a ejecutar el script
  if ! $tieneUltimaVersion
  then
    # Iniciamos de nuevo el script para ejecutar el script actualizado
    exec ./alias.sh
  fi
fi

# Iniciamos el script
if ! [ -z $1 ]
then
	parseOption $1 $2
	exit
else
  parseOption
fi
