#!/bin/bash

wrong_arguments () {

  echo -e "\nMissing: arg1 [arg2]\n"
  echo -e " ---------------------------------------------------------------"
  echo -e "| arg1     | arg2                 | Description                 |"
  echo -e " ---------------------------------------------------------------"
  echo -e "| install  | mainnet / devnet     | Install Core                |"
  echo -e "| update   |                      | Update Core                 |"
  echo -e "| remove   |                      | Remove Core                 |"
  echo -e "| secret   | set / clear          | Delegate Secret Set / Clear |"
  echo -e "| start    | relay / forger / all | Start Core Services         |"
  echo -e "| restart  | relay / forger / all | Restart Core Services       |"
  echo -e "| stop     | relay / forger / all | Stop Core Services          |"
  echo -e "| logs     | relay / forger / all | Show Core Logs              |"
  echo -e "| snapshot | create / restore     | Snapshot Create / Restore   |"
  echo -e "| system   | info / update        | System Info / Update        |"
  echo -e " ---------------------------------------------------------------\n"
  exit 1

}

pm2status () {

   echo $(pm2 describe $1 2>/dev/null)

}

start () {

  local secrets=$(cat $data/config/delegates.json | jq -r '.secrets')

  if [ "$1" = "all" ]; then

    local fstatus=$(pm2status "${name}-core-forger" | awk '{print $13}')
    local rstatus=$(pm2status "${name}-core-relay" | awk '{print $13}')

    if [[ "$rstatus" != "online" && "$2" = "mainnet" ]]; then
      pm2 --name "${name}-core-relay" start $core/packages/core/bin/$name -- relay --config $data/config --network $2 > /dev/null 2>&1
    elif [[ "$rstatus" != "online" && "$2" = "devnet" ]]; then
      pm2 --name "${name}-core-relay" start $core/packages/core/dist/index.js -- relay --config $data/config --network $2 > /dev/null 2>&1
    else
      echo -e "\nProcess relay already running. Skipping..."
    fi

    if [ "$secrets" = "[]" ]; then
      echo -e "\nDelegate secret is missing. Forger start aborted!"
    elif [[ "$fstatus" != "online" && "$2" = "mainnet" ]]; then
      pm2 --name "${name}-core-forger" start $core/packages/core/bin/$name -- forger --config $data/config --network $2 > /dev/null 2>&1
    elif [[ "$fstatus" != "online" && "$2" = "devnet" ]]; then
      pm2 --name "${name}-core-forger" start $core/packages/core/dist/index.js -- forger --config $data/config --network $2 > /dev/null 2>&1
    else
      echo -e "\nProcess forger already running. Skipping..."
    fi

  else

    local pstatus=$(pm2status "${name}-core-$1" | awk '{print $13}')

    if [[ "$secrets" = "[]" && "$1" = "forger" ]]; then
      echo -e "\nDelegate secret is missing. Forger start aborted!"
    elif [[ "$pstatus" != "online" && "$2" = "mainnet" ]]; then
      pm2 --name "${name}-core-$1" start $core/packages/core/bin/$name -- $1 --config $data/config --network $2 > /dev/null 2>&1
    elif [[ "$pstatus" != "online" && "$2" = "devnet" ]]; then
      pm2 --name "${name}-core-$1" start $core/packages/core/dist/index.js -- $1 --config $data/config --network $2 > /dev/null 2>&1
    else
      echo -e "\nProcess $1 already running. Skipping..."
    fi

  fi

  pm2 save > /dev/null 2>&1

}

restart () {

  if [ "$1" = "all" ]; then

    local fstatus=$(pm2status "${name}-core-forger" | awk '{print $13}')
    local rstatus=$(pm2status "${name}-core-relay" | awk '{print $13}')

    if [ "$rstatus" = "online" ]; then
      pm2 restart ${name}-core-relay > /dev/null 2>&1
    else
      echo -e "\nProcess relay not running. Skipping..."
    fi

    if [ "$fstatus" = "online" ]; then
      pm2 restart ${name}-core-forger > /dev/null 2>&1
    else
      echo -e "\nProcess forger not running. Skipping..."
    fi

  else

    local pstatus=$(pm2status "${name}-core-$1" | awk '{print $13}')

    if [ "$pstatus" = "online" ]; then
      pm2 restart ${name}-core-$1 > /dev/null 2>&1
    else
      echo -e "\nProcess $1 not running. Skipping..."
    fi

  fi

}

stop () {

  if [ "$1" = "all" ]; then

    local fstatus=$(pm2status "${name}-core-forger" | awk '{print $13}')
    local rstatus=$(pm2status "${name}-core-relay" | awk '{print $13}')

    if [ "$rstatus" = "online" ]; then
      pm2 stop ${name}-core-relay > /dev/null 2>&1
    else
      echo -e "\nProcess relay not running. Skipping..."
    fi

    if [ "$fstatus" = "online" ]; then
      pm2 stop ${name}-core-forger > /dev/null 2>&1
    else
      echo -e "\nProcess forger not running. Skipping..."
    fi

  else

    local pstatus=$(pm2status "${name}-core-$1" | awk '{print $13}')

    if [ "$pstatus" = "online" ]; then
      pm2 stop ${name}-core-$1 > /dev/null 2>&1
    else
      echo -e "\nProcess $1 not running. Skipping..."
    fi

  fi

  pm2 save > /dev/null 2>&1

}

install_deps () {

  sudo apt install -y htop curl build-essential python git nodejs npm libpq-dev ntp gawk jq > /dev/null 2>&1
  sudo npm install -g n grunt-cli pm2 yarn lerna > /dev/null 2>&1
  sudo n 10 > /dev/null 2>&1
  pm2 install pm2-logrotate > /dev/null 2>&1

  local pm2startup="$(pm2 startup | tail -n1)"
  eval $pm2startup > /dev/null 2>&1
  pm2 save > /dev/null 2>&1

}

secure () {

  sudo apt install -y ufw fail2ban > /dev/null 2>&1
  sudo ufw allow 22/tcp > /dev/null 2>&1
  sudo ufw allow ${api_port}/tcp > /dev/null 2>&1
  if [ "$1" = "mainnet" ]; then
    sudo ufw allow ${mainnet_port}/tcp > /dev/null 2>&1
  else
    sudo ufw allow ${devnet_port}/tcp > /dev/null 2>&1
  fi
  sudo ufw --force enable > /dev/null 2>&1
  sudo sed -i "/^PermitRootLogin/c PermitRootLogin prohibit-password" /etc/ssh/sshd_config > /dev/null 2>&1
  sudo systemctl restart sshd.service > /dev/null 2>&1

}

install_db () {

  sudo apt install -y postgresql postgresql-contrib > /dev/null 2>&1
  sudo -u postgres psql -c "CREATE USER $USER WITH PASSWORD 'password' CREATEDB;" > /dev/null 2>&1
  dropdb ${name}_$1 > /dev/null 2>&1
  createdb ${name}_$1 > /dev/null 2>&1

}

install_core () {

  if [ "$1" = "mainnet" ]; then
    git clone $repo $core > /dev/null 2>&1
  else
    git clone $repo $core -b $devbranch > /dev/null 2>&1
  fi

  mkdir $data > /dev/null 2>&1
  sudo rm -rf $HOME/.config > /dev/null 2>&1

  if [ "$1" = "mainnet" ]; then
    cd $core > /dev/null 2>&1
    lerna clean -y > /dev/null 2>&1
    lerna bootstrap > /dev/null 2>&1
    cp -rf "$core/packages/core/lib/config/$1" "$data" > /dev/null 2>&1
    cp "$core/packages/crypto/lib/networks/$name/$1.json" "$data/$1/network.json" > /dev/null 2>&1
  else
    cd $core > /dev/null 2>&1
    yarn setup > /dev/null 2>&1
    cp -rf "$core/packages/core/src/config/$1" "$data" > /dev/null 2>&1
  fi

  mv "$data/$1" "$data/config" > /dev/null 2>&1

  local envFile="$data/.env"
  touch "$envFile"

  echo "${token}_LOG_LEVEL=$log_level" >> "$envFile" 2>&1
  echo "${token}_DB_HOST=localhost" >> "$envFile" 2>&1
  echo "${token}_DB_PORT=5432" >> "$envFile" 2>&1
  echo "${token}_DB_USERNAME=$USER" >> "$envFile" 2>&1
  echo "${token}_DB_PASSWORD=password" >> "$envFile" 2>&1
  echo "${token}_DB_DATABASE=${name}_$1" >> "$envFile" 2>&1
  echo "${token}_P2P_HOST=0.0.0.0" >> "$envFile" 2>&1

  if [ "$1" = "mainnet" ]; then
    echo "${token}_P2P_PORT=$mainnet_port" >> "$envFile" 2>&1
  else
    echo "${token}_P2P_PORT=$devnet_port" >> "$envFile" 2>&1
  fi

  echo "${token}_API_HOST=0.0.0.0" >> "$envFile" 2>&1
  echo "${token}_API_PORT=$api_port" >> "$envFile" 2>&1
  echo "${token}_WEBHOOKS_HOST=0.0.0.0" >> "$envFile" 2>&1
  echo "${token}_WEBHOOKS_PORT=$wh_port" >> "$envFile" 2>&1
  echo "${token}_GRAPHQL_HOST=0.0.0.0" >> "$envFile" 2>&1
  echo "${token}_GRAPHQL_PORT=$gql_port" >> "$envFile" 2>&1
  echo "${token}_JSONRPC_HOST=0.0.0.0" >> "$envFile" 2>&1
  echo "${token}_JSONRPC_PORT=$rpc_port" >> "$envFile" 2>&1
}

update () {

  if [ "$1" = "mainnet" ]; then
    cd $core > /dev/null 2>&1
    git pull > /dev/null 2>&1
    lerna clean -y > /dev/null 2>&1
    lerna bootstrap > /dev/null 2>&1
  else
    cd $core > /dev/null 2>&1
    git pull > /dev/null 2>&1
    yarn setup > /dev/null 2>&1
  fi

  local fstatus=$(pm2status "${name}-core-forger" | awk '{print $13}')
  local rstatus=$(pm2status "${name}-core-relay" | awk '{print $13}')

  if [ "$rstatus" = "online" ]; then
    pm2 restart ${name}-core-relay > /dev/null 2>&1
  fi

  if [ "$fstatus" = "online" ]; then
    pm2 restart ${name}-core-forger > /dev/null 2>&1
  fi

}

remove () {

  pm2 delete ${name}-core-forger > /dev/null 2>&1
  pm2 delete ${name}-core-relay > /dev/null 2>&1
  pm2 save > /dev/null 2>&1
  rm -rf $core && rm -rf $data > /dev/null 2>&1
  sudo rm -rf $HOME/.config > /dev/null 2>&1
  dropdb ${name}_$1 > /dev/null 2>&1
  sudo ufw delete allow ${api_port}/tcp > /dev/null 2>&1
  if [ "$1" = "mainnet" ]; then
    sudo ufw delete allow ${mainnet_port}/tcp > /dev/null 2>&1
  else
    sudo ufw delete allow ${devnet_port}/tcp > /dev/null 2>&1
  fi

}

sysinfo () {

  local sockets="$(lscpu | grep "Socket(s):" | head -n1 | awk '{ printf $2 }')"
  local cps="$(lscpu | grep "Core(s) per socket:" | awk '{ printf $4 }')"
  local tpc="$(lscpu | grep "Thread(s) per core:" | awk '{ printf $4 }')"
  local os="$(lsb_release -d | awk '{ for (i=2;i<=NF;++i) printf $i " " }')"
  local cpu="$(lscpu | grep "Model name" | awk '{ for (i=3;i<=NF;++i) printf $i " " }')"
  local mhz="$(lscpu | grep "CPU MHz:" | awk '{ printf $3 }' | cut -f1 -d".")"
  local maxmhz="$(lscpu | grep "CPU max MHz:" | awk '{ printf $4 }' | cut -f1 -d".")"
  local hn="$(hostname --fqdn)"
  local ips="$(hostname --all-ip-address)"

  echo -e "\nSystem: $os"
  w | head -n1

  echo -e "\nCPU(s): ${sockets}x ${cpu}with $cps Cores and $[cps*tpc] Threads"
  echo -ne " Total: $[sockets*cps] Cores and $[sockets*cps*tpc] Threads"
  if [ -z "$maxmhz" ]; then
    echo -e " @ ${mhz}MHz"
  else
    echo -e " @ ${maxmhz}MHz"
  fi

  echo -e "\nHostname: $hn"
  echo -e " IP(s): $ips"

  echo -e ""
  free -h

  echo -e ""
  df -h /

  echo -e ""

}

sysupdate () {

  sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade -y > /dev/null 2>&1
  sudo apt-get autoremove -y > /dev/null 2>&1
  sudo apt-get autoclean -y > /dev/null 2>&1

}

logs () {

  if [ "$1" = "all" ]; then
    pm2 logs
  else
    pm2 logs ${name}-core-$1
  fi

}

secret () {

  if [ "$1" = "set" ]; then
    local scrt="$2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12} ${13}"
    jq --arg scrt "$scrt" '.secrets = [$scrt]' $data/config/delegates.json > delegates.tmp
  else
    jq '.secrets = []' $data/config/delegates.json > delegates.tmp
  fi

  mv delegates.tmp $data/config/delegates.json

}

snapshot () {

  if [ "$1" = "restore" ]; then

    local fstatus=$(pm2status "${name}-core-forger" | awk '{print $13}')
    local rstatus=$(pm2status "${name}-core-relay" | awk '{print $13}')

    stop all > /dev/null 2>&1

    dropdb ${name}_$network > /dev/null 2>&1
    createdb ${name}_$network > /dev/null 2>&1
    pg_restore -n public -O -j 8 -d ${name}_$network $HOME/snapshots/${name}_$network

    if [ "$rstatus" = "online" ]; then
      start relay $network > /dev/null 2>&1
    fi

    if [ "$fstatus" = "online" ]; then
      start forger $network > /dev/null 2>&1
    fi

  else

    if [ ! -d $HOME/snapshots ]; then
      mkdir $HOME/snapshots
    fi

    pg_dump -Fc ${name}_$network > $HOME/snapshots/${name}_${network}

  fi

}
