# detect package manager
if [ -x "$(command -v apt)" ]; then
  sudo apt update
  sudo apt upgrade
elif [ -x "$(command -v pacman)" ]; then
  sudo pacman -Syu
fi

