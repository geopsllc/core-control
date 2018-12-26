#!/bin/bash

. "config.conf"
. "functions.sh"

main () {

  git pull > /dev/null 2>&1

  i=1
  sp="/-\|"

  if [ -f $data/.env ]; then
    network="$(cat $data/.env | grep DATA | awk -F"_" '{print $4}')"
  fi

  if [[ ( "$1" == "install" ) && ( "$2" = "mainnet" || "$2" = "devnet" ) && ( -z "$3" ) ]]; then

    if [[ -d $data || -d $core ]]; then
      echo -e "\nCore already installed. Please uninstall first.\n"
      exit 1
    fi

    sudo apt update > /dev/null 2>&1

    sysinfo

    install_deps &

    echo -ne "Installing Dependencies...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone"

    secure $2 &

    echo -ne "Securing System...  "

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
      echo -e "\nCore not installed. Please install first.\n"
      exit 1
    fi

    sysinfo

    update $network &

    echo -ne "Updating Core...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  elif [[ ( "$1" == "remove" ) && ( -z "$2" ) ]]; then

    if [[ ! -d $data && ! -d $core ]]; then
      echo -e "\nCore not installed.\n"
      exit 1
    fi

    sudo apt update > /dev/null 2>&1

    sysinfo

    remove $network &

    echo -ne "Removing Core...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  elif [[ ( "$1" == "start" ) && ( "$2" = "relay" || "$2" = "forger" || "$2" = "all" ) && ( -z "$3" ) ]]; then

    if [[ ! -d $data || ! -d $core ]]; then
      echo -e "\nCore not installed. Please install first.\n"
      exit 1
    fi

    start $2 $network

    echo -e "\nAll Done!\n"

  elif [[ ( "$1" == "stop" ) && ( "$2" = "relay" || "$2" = "forger" || "$2" = "all" ) && ( -z "$3" ) ]]; then

    if [[ ! -d $data || ! -d $core ]]; then
      echo -e "\nCore not installed. Please install first.\n"
      exit 1
    fi

    stop "$2"

    echo -e "\nAll Done!\n"

  elif [[ ( "$1" == "system" ) && ( "$2" = "info"  )&& ( -z "$3" ) ]]; then

    sysinfo

  elif [[ ( "$1" == "system" ) && ( "$2" = "update"  ) && ( -z "$3" ) ]]; then

    sudo apt update > /dev/null 2>&1

    sysinfo

    sysupdate &

    echo -ne "Updating System...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  else

    wrong_arguments

  fi

  trap cleanup SIGINT SIGTERM SIGKILL

}

main "$@"
