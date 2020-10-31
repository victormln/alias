#!/bin/bash
# Filename: alias.sh
# Author: Víctor Molina Ferreira (github.com/victormln)
# Creating date: 12/11/16
# Version: 1.0

if ! zenity --question \
	--title "Creador de alias" \
	--ok-label="Continuar" \
	--cancel-label="Salir" \
	--text="`printf "Bienvenido al creador de alias. Te guiaré en el proceso.\n\nDeseas continuar?"`" &> /dev/null
then
	exit 1
fi
while [[ $? == 0 ]]; do
  informacion_alias=$(zenity --forms --title="Información del alias" --ok-label="Crear" --cancel-label="Cancelar" --text="Introduzca la información del alias que quiere crear" --separator=",/separador" --add-entry="Nombre del alias" --add-entry="Comando")
  nombre=$(awk -F,/separador '{print $1}' <<<$informacion_alias)
  comando=$(awk -F,/separador '{print $2}' <<<$informacion_alias)

	if [ -z "$nombre" ] &&  [ -z "$comando" ]
	then
		zenity --warning --title="Información" --text="No se ha introducido ningún nombre/comando. No se ha creado ningún alias."
		exit 1
	fi

  echo alias $nombre=\"$comando\" >> ${FILE_WITH_ALIAS}
  continuar=$(zenity --question \
  --text="¿Quieres crear otro alias?")
done

zenity --info \
--text="¡Alias creados!"
