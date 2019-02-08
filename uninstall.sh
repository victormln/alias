#!/bin/sh
# Uninstall

OSTYPE="Linux"
if [ "$(uname)" == "Darwin" ]; then
  OSTYPE="Darwin"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ] ||
  [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    OSTYPE="Windows"
fi

sed="sed -i"
if [[ $OSTYPE == "Darwin" ]]; then
  sed="sed -i ''"
fi

for rc in bashrc zshrc; do
  if [ -f "$HOME/.$rc" ]; then
    $sed '/alias malias/d' "$HOME/.$rc" && $sed '/alias uninstall_malias/d' "$HOME/.$rc" &&
      printf "Removed malias from %s\n" "$HOME/.$rc" && source "$HOME/.$rc"
  fi
done