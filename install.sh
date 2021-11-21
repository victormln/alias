#!/bin/bash

ERROR='\033[0;31m'
BLUE='\033[0;34m'
OK='\033[0;32m'
NC='\033[0m'

shell_file="bashrc"
if echo "$SHELL" | grep zsh > /dev/null
then
    shell_file="zshrc"
fi
chmod +x ~/.alias/alias.sh
echo "alias malias=\"~/.alias/alias.sh\"" >> ~/.$shell_file
echo "alias uninstall_malias=\"~/.alias/uninstall.sh\"" >> ~/.$shell_file
echo -e "${OK}[OK]${NC} Installed successfully."
echo -e "Now, you can execute: "${BLUE}source ~/.$shell_file${NC}" and then use malias. To check that everything is OK, use: ${BLUE}malias -v${NC}."
exit
