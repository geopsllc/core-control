#!/bin/bash

. "config.conf"
. "functions.sh"

main () {

  git pull > /dev/null 2>&1

  i=1
  sp="/-\|"

  if [[ ( "$1" != "install" ) && ( "$1" != "system" ) ]]; then

    if [ -f $data/.env ]; then
      network="$(cat $data/.env | grep DATA | awk -F"_" '{print $4}')"
    else
      echo -e "\nCore not properly installed. Please install first.\n"
      exit 1
    fi

  fi

  if [[ ( "$1" == "install" ) && ( "$2" = "mainnet" || "$2" = "devnet" ) && ( -z "$3" ) ]]; then

    if [[ -d $data || -d $core ]]; then
      echo -e "\nCore already installed. Please uninstall first.\n"
      exit 1
    fi

    system

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

    echo -ne "Setting up Core...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  elif [[ ( "$1" == "update" ) && ( -z "$2" ) ]]; then

    if [[ ! -d $data || ! -d $core ]]; then
      echo "\nCore not installed. Please install first.\n"
      exit 1
    fi

    system

    update $network &

    echo -ne "Updating Core...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  elif [[ ( "$1" == "remove" ) && ( -z "$2" ) ]]; then

    system

    remove $network &

    echo -ne "Removing Core...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  elif [[ ( "$1" == "start" ) && ( "$2" = "relay" || "$2" = "forger" || "$2" = "all" ) && ( -z "$3" ) ]]; then

    start $2 $network

    echo -e "\nAll Done!\n"

  elif [[ ( "$1" == "stop" ) && ( "$2" = "relay" || "$2" = "forger" || "$2" = "all" ) && ( -z "$3" ) ]]; then

    stop "$2"

    echo -e "\nAll Done!\n"

  elif [[ ( "$1" == "system" ) && ( -z "$2" ) ]]; then

    system

  else

    wrong_arguments

  fi

  trap cleanup SIGINT SIGTERM SIGKILL

}

main "$@"
