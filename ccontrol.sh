#!/bin/bash

basedir="$(dirname "$(cat $HOME/.bashrc | grep ccontrol | awk -F"=" '{print $2}')")"
execdir="$(dirname "$0")"

if [[ "$basedir" != "." && "$execdir" != "." ]]; then
  cd $basedir
elif [[ "$basedir" = "." && "$execdir" != "." ]]; then
  cd $PWD/$execdir
fi

. "project.conf"
. "functions.sh"
. "misc.sh"

main () {

  if [[ ( "$1" = "install" ) && ( "$2" = "core" || -z "$2" ) && ( -z "$3" ) ]]; then

    if [[ -d $data || -d $core ]]; then
      echo -e "\nCore already installed. Please remove first.\n"
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

    secure &

    echo -ne "Securing System...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone"

    install_db &

    echo -ne "Installing Database...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone"

    install_core &

    echo -ne "Setting up Core...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  elif [[ ( "$1" = "update" ) && ( "$2" = "core" ) && ( -z "$3" ) ]]; then

    if [[ ! -d $data || ! -d $core ]]; then
      echo -e "\nCore not installed. Please install first.\n"
      exit 1
    fi

    sysinfo
    update &

    echo -ne "Updating Core...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  elif [[ ( "$1" = "remove" ) && ( "$2" = "core" || -z "$2" ) && ( -z "$3" ) ]]; then

    if [[ ! -d $data && ! -d $core ]]; then
      echo -e "\nCore not installed.\n"
      exit 1
    fi

    sudo apt update > /dev/null 2>&1
    sysinfo
    remove &

    echo -ne "Removing Core...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  elif [[ ( "$1" = "config" ) && ( "$2" = "reset"  ) && ( -z "$3" ) ]]; then

    if [[ ! -d $data || ! -d $core ]]; then
      echo -e "\nCore not installed. Please install first.\n"
      exit 1
    fi

    config_reset &

    sleep 1
    echo -e "\nProcesses Stopped..."
    sleep 1
    echo -e "Configs Replaced with Defaults..."
    echo -e "All Done!\n"

  elif [[ ( "$1" = "start" ) && ( "$2" = "relay" || "$2" = "forger" || "$2" = "all" || -z "$2" ) && ( -z "$3" ) ]]; then

    if [[ ! -d $data || ! -d $core ]]; then
      echo -e "\nCore not installed. Please install first.\n"
      exit 1
    fi

    if [ -z "$2" ]; then
      set -- "$1" "all"
    fi

    start $2

    echo -e "\nAll Done!\n"

  elif [[ ( "$1" = "restart" ) && ( "$2" = "relay" || "$2" = "forger" || "$2" = "all" || -z "$2" ) && ( -z "$3" ) ]]; then

    if [[ ! -d $data || ! -d $core ]]; then
      echo -e "\nCore not installed. Please install first.\n"
      exit 1
    fi

    if [ -z "$2" ]; then
      set -- "$1" "all"
    fi

    restart $2

    echo -e "\nAll Done!\n"

  elif [[ ( "$1" = "stop" ) && ( "$2" = "relay" || "$2" = "forger" || "$2" = "all" || -z "$2" ) && ( -z "$3" ) ]]; then

    if [[ ! -d $data || ! -d $core ]]; then
      echo -e "\nCore not installed. Please install first.\n"
      exit 1
    fi

    if [ -z "$2" ]; then
      set -- "$1" "all"
    fi

    stop $2

    echo -e "\nAll Done!\n"

  elif [[ ( "$1" = "system" ) && ( "$2" = "info"  ) && ( -z "$3" ) ]]; then

    sysinfo

  elif [[ ( "$1" = "system" ) && ( "$2" = "update"  ) && ( -z "$3" ) ]]; then

    sudo apt update > /dev/null 2>&1
    sysinfo
    sysupdate &

    echo -ne "Updating System...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  elif [[ ( "$1" = "logs" ) && ( "$2" = "relay" || "$2" = "forger" || "$2" = "all" || -z "$2" ) && ( -z "$3" ) ]]; then

    if [ -z "$2" ]; then
      set -- "$1" "all"
    fi

    logs $2

  elif [[ ( "$1" = "secret" ) && ( ( "$2" = "set" && ! -z "${14}" && -z "${15}" ) || ( "$2" = "clear" && -z "$3" ) ) ]]; then

    if [[ ! -d $data || ! -d $core ]]; then
      echo -e "\nCore not installed. Please install first.\n"
      exit 1
    fi

    secret $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13} ${14}

    echo -e "\nAll Done!\n"

  elif [[ ( "$1" = "snapshot" ) && ( "$2" = "create" || "$2" = "restore" ) && ( -z "$3" ) ]]; then

    if [[ ! -d $data || ! -d $core ]]; then
      echo -e "\nCore not installed. Please install first.\n"
      exit 1
    fi

    if [[ "$2" = "restore" && ! -f $HOME/snapshots/${name}_$network ]]; then
      echo -e "\nFile $HOME/snapshots/${name}_$network Not Found!\n"
      exit 1
    fi

    sysinfo
    snapshot $2 &

    echo -ne "Processing Snapshot...  "

    while [ -d /proc/$! ]; do
      printf "\b${sp:i++%${#sp}:1}" && sleep .1
    done

    echo -e "\bDone\n"

  elif [[ ( "$1" = "update" ) && ( "$2" = "self" ) && ( -z "$3" ) ]]; then

    git pull

  elif [[ ( "$1" = "remove" ) && ( "$2" = "self" ) && ( -z "$3" ) ]]; then

    selfremove

  elif [[ ( "$1" = "update" ) && ( "$2" = "check" || -z "$2" ) && ( -z "$3" ) ]]; then

    update_info

  else

    wrong_arguments

  fi

  trap cleanup SIGINT SIGTERM SIGKILL

}

main "$@"
