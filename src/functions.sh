function aliasAdded {
  echo -e "$ALIAS_CREATED_MESSAGE"
}

function showExecuteSourceMessage {
  echo -e "$EXECUTE_SOURCE_COMMAND" "source ${FILE_WITH_ALIAS}" "${NC}"
}

function executeSourceAlias {
  source "${FILE_WITH_ALIAS}"
}

function printOptions {
    echo "[y/n Y/N]"
}

function checkShell {
    error_level=$(echo $?)
    if [ -z "${FILE_WITH_ALIAS}" ]
    then
        if [ $error_level -eq 0 ]
        then
            FILE_WITH_ALIAS=~/.zshrc
        else
            FILE_WITH_ALIAS=~/.bashrc
        fi
    fi
}

function importAlias {
    if [ -z "$1" ]
    then
        echo -e "$EMPTY_IMPORT_FILE_GIVEN"
        exit
    fi
    if ! [ -e "$CURRENT_DIR/$1" ]
    then
        echo -e "$IMPORT_FILE_NOT_FOUND [$CURRENT_DIR/$1]"
        exit
    fi
    numberAlias=$(cat "$CURRENT_DIR/$1" | wc -l) > /dev/null
    echo -e "$IMPORT_ALIAS $1"
    echo -en "$CONFIRM_ALIAS_IMPORT"; read -r import
    confirmYes "$import"
    $(cat "$CURRENT_DIR/$1" >> ${FILE_WITH_ALIAS})
    echo -e "$IMPORT_DONE"
}

function installAlias {
    if [ -z "$1" ]
    then
        echo -e "$EMPTY_INSTALL_FILE_GIVEN"
        exit
    fi
    if [[ $1 =~ ^http?(s)://* ]]
    then 
        installAliasesFromUrl $1
        exit
    fi
    exit
    if ! [ -e "$INSTALL_ALIAS_DIRECTORY/alias/$1.txt" ]
    then
        echo -e "$ALIAS_NAME_NOT_EXISTS [$1]"
        exit
    fi
    installAliasesFromFile $1
}

function addAlias {
  echo -e "$INSERT_COMMAND_MESSAGE ${ORANGE}$name${NC}:"
  read -e alias_command
  echo alias $name=\"$alias_command\" >> ${FILE_WITH_ALIAS}
  aliasAdded
  echo -en "$ASK_CREATE_ANOTHER_ALIAS ${CYAN}${CONFIRM_OPTIONS}${NC}: "; read continue
}

function installAliasesFromUrl {
    urlWithAliases=$1
    nameOfFileWithDownloadedAliases="install_aliases"
    validateThatUrlIsATextPlain $urlWithAliases
    if wget "$urlWithAliases" -O "$INSTALL_ALIAS_DIRECTORY"/alias/"$nameOfFileWithDownloadedAliases".txt 2>/dev/null; then
      installAliasesFromFile "$nameOfFileWithDownloadedAliases"
      rm -f "$INSTALL_ALIAS_DIRECTORY"/alias/"$nameOfFileWithDownloadedAliases".txt
    fi
}

function validateThatUrlIsATextPlain {
    if [[ ! `wget -S --spider $1  2>&1 | grep 'Content-Type: text/plain;'` ]]; 
    then
      echo -e "$URL_IS_NOT_RETURNING_A_FILE";
    fi
}

function installAliasesFromFile {
    numberAlias=$(cat "$INSTALL_ALIAS_DIRECTORY/alias/$1.txt" | wc -l)
    currentAliasName=$(head -n 1 "$INSTALL_ALIAS_DIRECTORY/alias/$1.txt")
    onlyName="${currentAliasName##* }"
    echo -e "$INSTALL_ALIAS $onlyName"
    $(cat "$INSTALL_ALIAS_DIRECTORY/alias/$1.txt" >> ${FILE_WITH_ALIAS})
    echo -e "$INSTALL_ALIAS_DONE $onlyName"
}

function add {
  echo -e ${NEW_ALIAS_WILL_BE_CREATED}
	continue="y"
	while confirmYes $continue
	do
    name=$1
    if [ -z "$1" ]
    then
      echo -e "$INSERT_NAME_OF_ALIAS_MESSAGE:"
      read name
      name=$(echo $name | sed 's/ //g')
    fi
    if cat ${FILE_WITH_ALIAS} | grep "^alias $name=" > /dev/null
    then
      echo -e "$ALIAS_EXISTS_MESSAGE"
      while cat ${FILE_WITH_ALIAS} | grep "^alias $name=" > /dev/null
      do
        echo -e "$CHOOSE_ANOTHER_NAME"
        read name
        name=$(echo $name | sed 's/ //g')
      done
      if [ $name == "q" ] || [ $name == "Q" ]
      then
        exit
      fi
      addAlias
    else
      addAlias
    fi
    shift
	done
}

function show {
  echo "$SHOW_ALIAS_CREATED"
  echo "*---------------------------------------------------*"
  # Cat temporal file with all alias
  cat ${FILE_WITH_ALIAS} | grep -E "^alias " > .alias.tmp
  while read linea
  do
    nombreScript=$(echo "$linea" | cut -d"=" -f 1)
    comando=$(echo "$linea" | cut -d"=" -f 2-)
    # Delete word alias to show only the value of alias
    echo -e " ${ORANGE}$nombreScript${NC}=$comando" | sed 's/alias //g'
    contador=$(($contador + 1))
  done < .alias.tmp
  rm .alias.tmp
  echo "*---------------------------------------------------*"
  echo "$SCRIPT_OPTIONS"
  exit
}

function edit {
  # Show all alias
  cat ${FILE_WITH_ALIAS} | grep -E "^alias " > .alias.tmp
  
  if [ -z $1 ]
  then
    showAlias
    echo "$SELECT_ALIAS_TO_EDIT"
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
  else
    for param in "$@"
    do
      if cat .alias.tmp | grep "^alias $param=" > /dev/null
      then
        editSpecificAlias $param
      else
        echo -e "$ALIAS_DOES_NOT_EXISTS ${ORANGE}$param${NC}"
        edit
      fi
    done
  fi
}

function editSpecificAlias {
  if checkIfAliasNameIsDuplicated $1
  then
    echo -e $ALIAS_DUPLICATED_MESSAGE
    exit
  fi
  commando=$(cat .alias.tmp | grep -E "alias $1=$2" | cut -d"=" -f 2 | head -1)
  temp="${commando%\"}"
  commando="${temp#\"}"
  echo -e "$SELECTED_ALIAS ${ORANGE}$1${NC}"
  echo "$INSERT_NAME_OF_ALIAS_MESSAGE:"
  if [[ $OS_TYPE == "Darwin" ]]; then
    read -p "(current: $1): " name
    if [[ -z $name ]]
    then
      name=$1
    fi
  else
    if [[ $OS_TYPE == "Darwin" ]]; then
      read -p "(current: $1): " name
      if [[ -z $name ]]
      then
        name=$1
      fi
    else
      read -e -i "$1" name
    fi
  fi
  name=$(echo $name | sed 's/ //g')
  echo -e "$INSERT_COMMAND_MESSAGE ${ORANGE}$name${NC}:"
  if [[ $OS_TYPE == "Darwin" ]]; then
    read -p "(current: $commando): " alias_command
    if [[ -z $alias_command ]]
    then
      alias_command=$commando
    fi
  else
    if [[ $OS_TYPE == "Darwin" ]]; then
      read -p "(current: $commando): " alias_command
      if [[ -z $alias_command ]]
      then
        alias_command=$commando
      fi
    else
      read -e -i "$commando" alias_command
    fi
  fi
  cp ${FILE_WITH_ALIAS} ${DIR_BACKUP}.alias_backup.txt
  if cat ${FILE_WITH_ALIAS} | grep "^alias $1=\"$commando\"" &> /dev/null
  then
    sed "1!{/^alias $1=/d;}" ${FILE_WITH_ALIAS} > ~/bash.txt
    echo alias $name=\"$alias_command\" >> ~/bash.txt
  else
    sed "1!{/^alias $1=/d;}" ${FILE_WITH_ALIAS} > ~/bash.txt
    echo alias $name=\"$alias_command\" >> ~/bash.txt
  fi
  rm ${FILE_WITH_ALIAS}
  mv ~/bash.txt ${FILE_WITH_ALIAS}
  if [ $? -eq 0 ]
  then
    echo -e "$ALIAS_MODIFIED_SUCCESFULLY"
  else
    echo -e "$UNKNOWN_PROBLEM"
  fi
}

function checkIfAliasNameIsDuplicated {
  numberOfRepeteadAlias=$(grep -c "^alias $1=" ${FILE_WITH_ALIAS})
  if [ $numberOfRepeteadAlias -gt 1 ]
  then
    return 0
  fi

  return 1
}

function delete {
  cat ${FILE_WITH_ALIAS} | grep -E "^alias " > .alias.tmp
  if [ -z $1 ]
  then
    showAlias
    echo "$NUMBER_OF_THE_ALIAS_TO_BE_DELETED"
    read selectedOption
    if [[ "$selectedOption" =~ ^[0-9]+$ ]]
    then
      nombre=$(sed "$selectedOption!d" .alias.tmp | cut -d"=" -f 1 | cut -d" " -f 2)
      deleteSpecificAlias $nombre
    else
      deleteSpecificAlias $selectedOption
    fi
    rm .alias.tmp
  else
    for param in "$@"
    do
      if cat .alias.tmp | grep "^alias $param=" > /dev/null
      then
        deleteSpecificAlias $param
      else
        echo -e "$ALIAS_DOES_NOT_EXISTS ${ORANGE}$param${NC}"
        delete
      fi
    done
  fi
}

function deleteSpecificAlias {
  comando=$(cat .alias.tmp | grep -E "alias $1=" | cut -d"=" -f 2 | head -1)
  if checkIfAliasNameIsDuplicated $1
  then
    echo -e $ALIAS_DUPLICATED_MESSAGE
    exit
  fi
  temp="${commando%\"}"
  comando="${temp#\"}"
  echo -en "$CONFIRM_ALIAS_DELETE ${ORANGE}$1${NC}? ${CONFIRM_OPTIONS}: "; read confirmation
  if ! confirmYes $confirmation
  then
    exit 6
  fi
  cp ${FILE_WITH_ALIAS} ${DIR_BACKUP}.alias_backup.txt
  sed "1!{/^alias $1=/d;}" ${FILE_WITH_ALIAS} > ~/bash.txt
  rm ${FILE_WITH_ALIAS}
  mv ~/bash.txt ${FILE_WITH_ALIAS}
  if [ $? -eq 0 ]
  then
    echo -e "$ALIAS_DELETED_SUCCESSFULLY"
  else
    echo -e "$UNKNOWN_PROBLEM"
  fi
}

function clear {
  numberEmptyLines=$(grep -cvE '[^[:space:]]' ${FILE_WITH_ALIAS})
  numberEmptyAlias=$(grep '^alias .*=\"\"$' ${FILE_WITH_ALIAS} | wc -l)
  numberEmptyAliasWithoutQuotes=$(grep '^alias .*=$' ${FILE_WITH_ALIAS} | wc -l)
  numberEmptyAlias=$(($numberEmptyAlias + $numberEmptyAliasWithoutQuotes))
  if [ $numberEmptyLines != 0 ]
  then
    echo "$EMPTY_LINES_MESSAGE"
    echo -e "$DELETE_EMPTY_LINES_MESSAGE ${CYAN}$CONFIRM_OPTIONS${NC}"
    read delete
    if confirmYes $delete
    then
      sed="sed -i"
      if [[ $OS_TYPE == "Darwin" ]]; then
        sed="sed -i ''"
      fi
      $sed '/^\s*$/d' ${FILE_WITH_ALIAS}
      echo -e "$EMPTY_LINES_DELETED_SUCCESSFULLY"
    fi
  else
    echo -e "$NO_EMPTY_LINES_FOUND"
  fi
  if ! [ $numberEmptyAlias -eq 0 ]
  then
    echo "$EMPTY_ALIAS"
    echo -en "$DELETE_EMPTY_ALIAS"; read -r delete
    if confirmYes $delete
    then
      sed="sed -i"
      if [[ $OS_TYPE == "Darwin" ]]; then
        sed="sed -i ''"
      fi
      $sed '/^alias .*=\"\"*$/d' ${FILE_WITH_ALIAS}
      $sed '/^alias .*=$/d' ${FILE_WITH_ALIAS}
      echo -e "$EMPTY_ALIAS_DELETED_SUCCESSFULLY"
    fi
  else
    echo -e "$NO_EMPTY_ALIAS_FOUND"
  fi
}

function copy {
  cat ${FILE_WITH_ALIAS} | grep -E "^alias " > .alias.tmp
  if [ -z $1 ]
  then
    showAlias
    echo "$SELECT_NUMBER_OF_ALIAS_TO_BE_COPIED"
    read selectedOption
    if [[ "$selectedOption" =~ ^[0-9]+$ ]]
    then
      nombre=$(sed "$selectedOption!d" .alias.tmp | cut -d"=" -f 1 | cut -d" " -f 2)
      copySpecificAlias $nombre
    else
      copySpecificAlias $selectedOption
    fi
    rm .alias.tmp
  else
    comandoOrigen=$1
    for param in "$@"
    do
      if cat .alias.tmp | grep "^alias $comandoOrigen=" > /dev/null
      then
        if [ -z $2 ]
        then
          copySpecificAlias $comandoOrigen
        else
          if ! [ "$comandoOrigen" == "$param" ]
          then
              copySpecificAlias $comandoOrigen $param
          fi
        fi
      else
        echo -e "$ALIAS_DOES_NOT_EXISTS ${ORANGE}$1${NC}"
        copy
      fi
    done
  fi
}

function copySpecificAlias {
  commando=$(cat .alias.tmp | grep -E "alias $1=" | cut -d"=" -f 2 | head -1)
  temp="${commando%\"}"
  commando="${temp#\"}"
  if [ -z $2 ]
  then
    echo -e "$SELECTED_ALIAS ${ORANGE}$1${NC}."
    echo "$INSERT_NAME_OF_ALIAS_MESSAGE:"
    read name_alias
    echo alias $name_alias=\"$commando\" >> ${FILE_WITH_ALIAS}
    echo -e "$ALIAS_COPIED_SUCCESSFULLY ${ORANGE}$name_alias${NC}."
  else
    echo alias $2=\"$commando\" >> ${FILE_WITH_ALIAS}
    if [ $? -eq 0 ]
    then
      echo -e "$ALIAS_COPIED_SUCCESSFULLY ${ORANGE}$2${NC}."
    else
      echo -e "$COPY_ERROR"
    fi
  fi
}

function confirmYes {
  if [ -z $1 ]
  then
    echo "$EXIT_SCRIPT_WITH_OPTIONS"
    exit 4
  fi
  if [ $1 == "y" ] || [ $1 == "Y" ] || [ $1 == "s" ] || [ $1 == "S" ]
  then
    return 0
  fi

  return 1
}

function showAlias {
  echo "$SHOW_ALIAS_CREATED"
  contador=1
  while read linea
  do
    nombreScript=$(echo "$linea" | cut -d"=" -f 1)
    comando=$(echo "$linea" | cut -d"=" -f 2)
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
    echo -e "$BACKUP_NOT_FOUND"
    echo "$ROUTE_BACKUP_MESSAGE"
  else
    cp ${DIR_BACKUP}.alias_backup.txt ${FILE_WITH_ALIAS}
    echo -e "$BACKUP_DONE"
  fi
}

function openFileWithAlias {
  $DEFAULT_EDITOR ${FILE_WITH_ALIAS}
}

function showHelp {
    echo -e "$USAGE_MESSAGE"

    echo -e "$ADD_OPTION_HELP_MESSAGE"
    echo -e "$EDIT_OPTION_HELP_USAGE"
    echo -e "$LIST_OPTION_HELP_USAGE"

    echo -e "$DELETE_OPTION_HELP_USAGE"

    echo -e "$COPY_OPTION_HELP_USAGE"
    echo -e "$CONFIG_OPTION_HELP_USAGE"
    echo -e "$RESTORE_HELP_MESSAGE"
    echo -e "$EMPTY_OPTION_HELP_MESSAGE"
    echo -e "$IMPORT_OPTION_USAGE"
    echo -e "$INSTALL_OPTION_USAGE"
}

function parseOption {
  if [ -z $1 ]
  then
    add
  else
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
      if [ -z $2 ]
      then
        edit
      else
        shift
        edit "$@"
      fi
  	elif [ $1 == "delete" ] || [ $1 == "-d" ]
  	then
        if [ -z $2 ]
        then
          delete
        else
          shift
          delete "$@"
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
        shift
        copy "$@"
      fi
  	elif [ $1 == "-h" ] || [ $1 == "--help" ]
  	then
  		showHelp
    elif [ $1 == "show" ] || [ $1 == "view" ] || [ $1 == "list" ] || [ $1 == "-l" ]
    then
      show
    elif [ $1 == "--clear" ]
    then
      clear
    elif [ $1 == "--restore" ]
    then
      restore
    elif [ $1 == "--import" ]
    then
      importAlias $2
    elif [ $1 == "--install" ] || [ $1 == "install" ]
    then
      installAlias $2
    elif [ $1 == "--conf" ]
    then
      echo ""
    elif [ $1 == "--open" ] || [ $1 == "open" ]
    then
      openFileWithAlias
    else
      showHelp
  	fi
  fi
}
