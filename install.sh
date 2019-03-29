#!/bin/bash

ERROR='\033[0;31m'
BLUE='\033[0;34m'
OK='\033[0;32m'
NC='\033[0m'

actualShell=$(echo $SHELL | grep zsh)
if [ $? -eq 0 ]
then
    actualShell="zshrc"
else
    actualShell="bashrc"
fi
chmod +x ~/.alias/alias.sh
echo "alias malias=\"~/.alias/alias.sh\"" >> ~/.$actualShell
echo "alias uninstall_malias=\"~/.alias/uninstall.sh\"" >> ~/.$actualShell
echo -e "${OK}[OK]${NC} Installed successfully."
echo -e "Now, you can execute: "${BLUE}source ~/.$actualShell${NC}" and then use malias. To check that everything is OK, use: ${BLUE}malias -v${NC}."
exit
