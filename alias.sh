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

function aliasAdded {
  #Mostramos mensaje conforme se han creado los alias y se ha salido del programa
  echo "Alias creado!"
}

function add {
	continuar="y"
	# Preguntamos hasta que el usuario quiera, si quiere crear alias
	while [ $continuar == "y" ] || [ $continuar == "Y" ] ||
   [ $continuar == "s" ] || [ $continuar == "S" ]
	do
    echo -e "Introduce un nombre de alias"
    read name
    echo "Introduce ahora el comando que querrás ejecutar con el alias $name (no hace falta que pongas las comillas)"
    read alias_command
    #Añadimos al .bashrc el alias
    echo alias $name=\"$alias_command\" >> ~/.bashrc
    aliasAdded
    echo "Quieres crear otro alias? Escribe: [y / n] o [s / n] para continuar."
    read continuar
	done
}

function show {
  echo "Estos son los alias que tienes creados hasta ahora:"
  echo "*---------------------------------------------------*"
  # Meto todos los alias en un archivo temporal y los muestro
  cat ~/.bashrc | grep -E "^alias " > .alias.tmp
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
  cat ~/.bashrc | grep -E "^alias " > .alias.tmp
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
      echo "Has seleccionado el alias $selectedOption."
      editSpecificAlias $selectedOption
    fi
    rm .alias.tmp
  # En el caso que le haya pasado un argumento (el nombre de un alias)
  # podrá modificarlo, sino le muestra que ese nombre de alias, no existe
  else
    if $(cat ~/.bashrc | grep -E "^alias $1=")
    then
      echo "El alias $1 existe."
      # COPIAR LO MISMO QUE EN EL ELSE DE ARRIBA
      editSpecificAlias $1
    else
      echo "El alias $1 no existe. "
      echo "Introduce uno que exista (recuerda que puedes ejecutar el [edit] sin parámetros o ver los alias con [show] o [view])"
    fi
  fi
}

# A esta funcion le paso un argumento, que será el nombre del alias a editar
function editSpecificAlias {
  echo "Que nombre quieres ponerle?:"
  read name_alias
  echo "Que comando quieres que se ejecute con el alias $name_alias?:"
  read alias_command
  echo $selectedOption
  # Antes de nada, le hacemos una copia al usuario de su bashrc
  cp ~/.bashrc ~/.bashrc_copy_alias_script.txt
  # Sustituimos el comando antiguo, por el nuevo
  # la coma es el delimitador para el sed
  sed "s,^alias $selectedOption=\"$commando\",alias $name_alias=\"$alias_command\",g" ~/.bashrc > ~/bash.txt
  # Eliminamos
  rm ~/.bashrc
  mv ~/bash.txt ~/.bashrc
  if [ $? -eq 0 ]
  then
    echo "Se ha modificado el alias correctamente"
  else
    echo "Ha ocurrido un problema. Vuelva a ejecutar el script"
  fi
}

function delete {
  echo "delete"
}

function showHelp {
	echo "########"
	echo "Ayuda"
	echo "########"
	echo "Comandos disponibles:"
	echo "add -> Añade un alias"
	echo "edit -> Editar un alias"
	echo "delete -> Elimina un alias"
	echo "Sin argumentos -> Crea un alias"
	echo "Vuelve a ejecutar el script y selecciona una de esas opciones"
}

function parseOption {
  # En el caso de que el usuario no le haya pasado un argumento,
  # por defecto significa que quiere crear un alias
  if [ -z $1 ]
  then
    add
  else
    # Miramos que ha seleccionado el usuario (add, edit, delete, help, show)
    if [ $1 == "add" ]
  	then
  		add
  	elif [ $1 == "edit" ]
  	then
      # Si no le pasa un segundo argumento a edit (el nombre del alias)
      # le preguntaremos en el edit cual quiere modificar
      if [ -z $2 ]
      then
        edit
      else
        edit $2
      fi
  	elif [ $1 == "delete" ]
  	then
  		delete
  	elif [ $1 == "help" ]
  	then
  		showHelp
    elif [ $1 == "show" ] || [ $1 == "view" ]
    then
      show
    else
      # Cualquier otro parametro, mostramos la ayuda
      showHelp
  	fi
  fi
}

# Iniciamos el script
if ! [ -z $1 ]
then
	parseOption $1 $2
	exit
else
  parseOption
fi
