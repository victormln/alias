#!/bin/bash
# Filename: update.sh
# Author: Víctor Molina Ferreira (github.com/victormln)
# Creation date: 26/12/2016
# Version: 1.0

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

TODAY=$(date +%Y-%m-%d)

if ! command -v curl >/dev/null 2>&1; then
  echo -e "$CURL_NOT_INSTALLED_MESSAGE"
  exit 10
fi

if [[ "$TODAY" > "$LAST_UPDATE_CHECKED_IN" ]] || [ "$1" == "--update" ]; then
  sed="sed -i"
  if [ "$OS_TYPE" == "Linux" ]; then
    ping -c 1 8.8.8.8 &>/dev/null
    has_internet=$(echo $?)
    # Si es Windows
  elif [ "$OS_TYPE" == "Windows" ]; then
    ping -n 1 www.google.com >/dev/null
    has_internet=$(echo $?)
  elif [ "$OS_TYPE" == "Darwin" ]; then
    ping -c 1 8.8.8.8 &>/dev/null
    has_internet=$(echo $?)
    sed="sed -i ''"
  fi

  SCRIPT_DIRECTORY=$(cd $(dirname $0) && pwd)
  $sed 's,^\(LAST_UPDATE_CHECKED_IN=\).*,\1'"$TODAY"',' "$SCRIPT_DIRECTORY"/conf/user.conf
  rm "$SCRIPT_DIRECTORY/conf/user.conf''" >/dev/null
  if [ "$has_internet" -ne 0 ]; then
    echo -e "$NO_INTERNET_CONNECTION_MESSAGE"
  fi

  if $SEARCH_OTA || [ "$1" == "--update" ]; then
    last_version=$(curl -s https://raw.githubusercontent.com/victormln/alias/master/alias.sh | grep '# Version:' | cut -d: -f 2 | head -1) >/dev/null
    last_version=${last_version//[[:blank:]]/}
    last_version_without_dots=$(echo "$last_version" | tr -d ".")
    actual_version_without_dots=$(echo "$CURRENT_VERSION" | tr -d ".")
    if ((actual_version_without_dots >= last_version_without_dots)); then
      echo "###########################################"
      echo -e "$NEW_UPDATE_MESSAGE${NC}"
      echo "$YOU_HAVE_VERSION_MESSAGE: $CURRENT_VERSION"
      echo "$AVAILABLE_VERSION_MESSAGE: $last_version"
      echo "###########################################"

      if $AUTOMATIC_UPDATE; then
        echo "$AVAILABLE_VERSION_MESSAGE"
        git stash >/dev/null
        git pull origin master | tee >(echo "$UPDATING_PLEASE_WAIT_MESSAGE")
        echo -e "$UPDATE_DONE_MESSAGE"
      else
        echo "$AVAILABLE_UPDATE_MESSAGE"
        echo "$ASK_TO_DOWNLOAD_MESSAGE"
        read -r want_to_update
        if [ "$want_to_update" == "s" ] || [ "$want_to_update" == "y" ] || [ "$want_to_update" == "S" ] || [ "$want_to_update" == "Y" ]; then
          git stash >/dev/null
          git pull | tee >(echo "$UPDATING_PLEASE_WAIT_MESSAGE")
          echo -e "$UPDATE_DONE_MESSAGE"
          exit
        else
          echo -e "$NOT_UPDATED_MESSAGE"
          echo -e "**************************"
        fi
      fi
    fi
  fi
fi
