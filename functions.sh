#!/bin/bash

wrong_arguments () {

  echo "Possible arguments:"
  echo "install mainnet|devnet"
  echo "update mainnet|devnet"
  echo "uninstall mainnet|devnet"
  echo "start relay|forger|all mainnet|devnet"
  echo "stop relay|forger|all"
  exit 1

}

pm2status () {

   echo $(pm2 describe $1 2>/dev/null)

}

start () {

  if [ "$1" = "all" ]; then

    local fstatus=$(pm2status "${name}-core-forger" | awk '{print $13}')
    local rstatus=$(pm2status "${name}-core-relay" | awk '{print $13}')

    if [[ "$rstatus" != "online" && "$2" = "mainnet" ]]; then
      pm2 --name "${name}-core-relay" start $core/packages/core/bin/$name -- relay --config $data/config --network $2 > /dev/null 2>&1
    elif [[ "$rstatus" != "online" && "$2" = "devnet" ]]; then
      pm2 --name "${name}-core-relay" start $core/packages/core/dist/index.js -- relay --config $data/config --network $2 > /dev/null 2>&1
    else
      echo "Relay already running!"
    fi

    if [[ "$fstatus" != "online" && "$2" = "mainnet" ]]; then
      pm2 --name "${name}-core-forger" start $core/packages/core/bin/$name -- forger --config $data/config --network $2 > /dev/null 2>&1
    elif [[ "$fstatus" != "online" && "$2" = "devnet" ]]; then
      pm2 --name "${name}-core-forger" start $core/packages/core/dist/index.js -- forger --config $data/config --network $2 > /dev/null 2>&1
    else
      echo "Forger already running!"
    fi

  else

    local status=$(pm2status "${name}-core-$1" | awk '{print $13}')

    if [[ "$status" != "online" && "$2" = "mainnet" ]]; then
      pm2 --name "${name}-core-$1" start $core/packages/core/bin/$name -- $1 --config $data/config --network $2 > /dev/null 2>&1
    elif [[ "$status" != "online" && "$2" = "devnet" ]]; then
      pm2 --name "${name}-core-$1" start $core/packages/core/dist/index.js -- $1 --config $data/config --network $2 > /dev/null 2>&1
    else
      echo "Process already running!"
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
      echo "Relay already stopped!"
    fi

    if [ "$fstatus" = "online" ]; then
      pm2 stop ${name}-core-forger > /dev/null 2>&1
    else
      echo "Forger already stopped!"
    fi

  else

    local status=$(pm2status "${name}-core-$1" | awk '{print $13}')

    if [ "$status" = "online" ]; then
      pm2 stop ${name}-core-$1 > /dev/null 2>&1
    else
      echo "Process already stopped!"
    fi

  fi

}

install_deps () {

  sudo apt install -y htop curl build-essential python git nodejs npm libpq-dev ntp > /dev/null 2>&1
  sudo npm install -g n grunt-cli pm2 yarn lerna > /dev/null 2>&1
  sudo n 10 > /dev/null 2>&1

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
    git clone $repo $core -b develop > /dev/null 2>&1
  fi

  mkdir $data > /dev/null 2>&1

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
  echo "${token}_WEBHOOKS_PORT=4004" >> "$envFile" 2>&1
  echo "${token}_GRAPHQL_HOST=0.0.0.0" >> "$envFile" 2>&1
  echo "${token}_GRAPHQL_PORT=4005" >> "$envFile" 2>&1
  echo "${token}_JSONRPC_HOST=0.0.0.0" >> "$envFile" 2>&1
  echo "${token}_JSONRPC_PORT=8080" >> "$envFile" 2>&1
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

uninstall () {

  pm2 delete ${name}-core-forger > /dev/null 2>&1
  pm2 delete ${name}-core-relay > /dev/null 2>&1
  rm -rf $core && rm -rf $data > /dev/null 2>&1
  dropdb ${name}_$1 > /dev/null 2>&1

}
