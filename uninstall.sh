#!/bin/sh
# Uninstall

OS_TYPE="Linux"
if [ "$(uname)" == "Darwin" ]; then
  OS_TYPE="Darwin"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ] ||
  [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    OS_TYPE="Windows"
fi

sed="sed -i"
if [[ $OS_TYPE == "Darwin" ]]; then
  sed="sed -i ''"
fi

for rc in bashrc zshrc; do
  if [ -f "$HOME/.$rc" ]; then
    $sed '/alias malias/d' "$HOME/.$rc" && $sed '/alias uninstall_malias/d' "$HOME/.$rc" &&
      printf "Removed malias from %s\n" "$HOME/.$rc"
  fi
done