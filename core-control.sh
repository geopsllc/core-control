#!/bin/bash

. "config.conf"
. "functions.sh"

main ()
{
  i=1
  sp="/-\|"

  if [[ ( "$1" == "install" ) && ( "$2" = "mainnet" || "$2" = "devnet" ) ]]; then

    sudo apt update > /dev/null 2>&1

    install_deps &
    echo -ne "Installing Dependencies...  "
    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done
    echo -e "\bDone"

    install_db $2 &
    echo -ne "Installing Database...  "
    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done
    echo -e "\bDone"

    install_core $2 &
    echo -ne "Settng up Core...  "
    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done
    echo -e "\bDone"

  elif [[ ( "$1" == "uninstall" ) && ( "$2" = "mainnet" || "$2" = "devnet" ) ]]; then

    uninstall "$2" &
    echo -ne "Removing Core...  "
    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done
    echo -e "\bDone"

  elif [[ ( "$1" == "start" ) && ( "$2" = "relay" || "$2" = "forger" || "$2" = "all" ) && ( "$3" = "mainnet" || "$3" = "devnet" ) ]]; then

    start "$2" "$3"
    echo "All Done!"

  elif [[ ( "$1" == "stop" ) && ( "$2" = "relay" || "$2" = "forger" || "$2" = "all" ) ]]; then

    stop "$2"
    echo "All Done!"

  else

    wrong_arguments

  fi

  trap cleanup SIGINT SIGTERM SIGKILL
}

main "$@"
