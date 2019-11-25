#!/bin/bash

ERROR='\033[0;31m'
BLUE='\033[0;34m'
OK='\033[0;32m'
NC='\033[0m'

actual_shell=$(echo $SHELL | grep zsh)
if [ $? -eq 0 ]
then
    actual_shell="zshrc"
else
    actual_shell="bashrc"
fi
chmod +x ~/.alias/alias.sh
echo "alias malias=\"~/.alias/alias.sh\"" >> ~/.$actual_shell
echo "alias uninstall_malias=\"~/.alias/uninstall.sh\"" >> ~/.$actual_shell
echo -e "${OK}[OK]${NC} Installed successfully."
echo -e "Now, you can execute: "${BLUE}source ~/.$actual_shell${NC}" and then use malias. To check that everything is OK, use: ${BLUE}malias -v${NC}."
exit
