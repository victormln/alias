#!/bin/sh
# Uninstall

sed="sed -i"
if [[ $OSTYPE == "Darwin" ]]; then
  sed="sed -i ''"
fi

for rc in bashrc zshrc; do
  if [ -f "$HOME/.$rc" ]; then
    $sed '/alias malias/d' "$HOME/.$rc" > /dev/null 2>&1 &&
      printf "Removed malias from %s\n" "$HOME/.$rc"
  fi
done