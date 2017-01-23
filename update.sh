#!/bin/bash
# Fitxer: update.sh
# Autor: Víctor Molina Ferreira (victor)
# Data: 26/12/2016
# Versión: 1.0

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

#  Descripción: Comprueba si el script está a la ultima version

today=$(date +%Y-%m-%d)
if [[ "$today" > "$lastChecked" ]] || [ "$1" == "--update" ]
then
  # Compruebo que sistema está usando para hacer ping
  # Si es Linux o Mac
  if [ "$(uname -s)" == "Linux" ] || [ "$(uname)" == "Darwin" ]; then
      ping -c 1 8.8.8.8 &> /dev/null
      has_internet=$(echo $?)
      # Si es Windows
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ] ||
    [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
      ping -n 1 www.google.com > /dev/null
      has_internet=$(echo $?)
  fi

  # Si el ping se ha realizado correctamente es que tiene internet
  # por lo que se buscaran actualizaciones
  if [ $has_internet -eq 0 ]
  then
    # Si están activadas las actualizaciones automáticas
    if $search_ota || [ "$1" == "--update" ]
    then
      # Modifico el valor de la variable y pongo que se ha buscado una actualización
      # a fecha de hoy
      sed -i 's,^\(lastChecked=\).*,\1'$(date +%Y-%m-%d)',' user.conf
  		tieneUltimaVersion=false
  		# Conseguimos la ultima version que hay en github y le quitamos los puntos
  		ultimaVersion=$(curl -s https://raw.githubusercontent.com/victormln/alias/master/alias.sh) > /dev/null
      ultimaVersion=$(echo $ultimaVersion | grep '# Versión:' $0 | cut -d: -f 2 | head -1)
      ultimaVersion=${ultimaVersion//[[:blank:]]/}
      ultimaVersionSinPuntos=$( echo $ultimaVersion | tr -d ".")
  		# Miramos que versión tiene el usuario actualmente
  		versionActualSinPuntos=$(echo $CURRENTVERSION | tr -d ".")
  		# Comprobamos si la versionActual es igual o mas grande que la ultimaVersion
  		# es igual a la versionActual.
  		if (( $versionActualSinPuntos>=$ultimaVersionSinPuntos ))
  		then
  			tieneUltimaVersion=true
        if [ "$1" == "--update" ]
        then
          echo -e "$HAVELASTVERSION"
        fi
  		else
  			# Mostramos el mensaje de que hay una nueva actualización
  			echo "###########################################"
  			echo -e "$NEWUPDATEMESSAGE${NC}"
  			echo "$YOUHAVEVERSIONMESSAGE: $CURRENTVERSION"
  			echo "$AVAILABLEVERSIONMESSAGE: $ultimaVersion"
  			echo "###########################################"
  			# Si tiene las actualizaciones automaticas, no se le pide nada
  			if $automatic_update
  			then
  				# Si es así, hacemos un pull y le actualizamos el script
  				echo $AVAILABLEVERSIONMESSAGE
  				git pull | tee >(echo "$UPDATINGPLEASEWAITMESSAGE")
  				echo -e "$UPDATEDONEMESSAGE"
  			else
  			  echo "$AVAILABLEUPDATEMESSAGE"
  			  echo "$WANTTODOWNLOADMESSAGE"
  			  # Preguntamos si quiere actualizar
  			  read actualizar
  			  if [ $actualizar == "s" ] || [ $actualizar == "y" ]
  			  then
  			    # Si es así, hacemos un pull y le actualizamos el script
  			  	git pull | tee >(echo "$UPDATINGPLEASEWAITMESSAGE")
  					echo -e "$UPDATEDONEMESSAGE"
            exit
  			  else
  			    # En el caso que seleccione que no, muestro un mensaje.
  			    echo -e "$NOTUPDATEDMESSAGE"
  					echo -e "**************************"
  					# Damos por su puesto que tiene la ultima version,
  					# para que el script no entre en bucle
  					tieneUltimaVersion=true
  			  fi
  			fi
  		fi
    fi
  else
  	echo -e "$NOTHAVEINTERNETMESSAGE"
  fi
fi
