#!/bin/sh
# Uninstall

sed="sed -i"
if [[ $OSTYPE == "Darwin" ]]; then
  sed="sed -i ''"
fi

for rc in bashrc zshrc; do
  if [ -f "$HOME/.$rc" ]; then
    $sed '/malias/d' "$HOME/.$rc" &&
      printf "Removed malias from %s\n" "$HOME/.$rc"
  fi
done