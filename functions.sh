#!/bin/bash

wrong_arguments () {
  echo "Possible arguments:"
  echo "install mainnet|devnet"
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
    local fstatus=$(pm2status "ark-core-forger" | awk '{print $13}')
    local rstatus=$(pm2status "ark-core-relay" | awk '{print $13}')
    if [[ "$rstatus" != "online" && "$2" = "mainnet" ]]; then
      pm2 --name "ark-core-relay" start $HOME/ark-core/packages/core/bin/ark -- relay --config $HOME/.ark/config --network $2 > /dev/null 2>&1
    elif [[ "$rstatus" != "online" && "$2" = "devnet" ]]; then
      pm2 --name "ark-core-relay" start $HOME/ark-core/packages/core/dist/index.js -- relay --config $HOME/.ark/config --network $2 > /dev/null 2>&1
    else
      echo "Relay already running!"
    fi
    if [[ "$fstatus" != "online" && "$2" = "mainnet" ]]; then
      pm2 --name "ark-core-forger" start $HOME/ark-core/packages/core/bin/ark -- forger --config $HOME/.ark/config --network $2 > /dev/null 2>&1
    elif [[ "$fstatus" != "online" && "$2" = "devnet" ]]; then
      pm2 --name "ark-core-forger" start $HOME/ark-core/packages/core/dist/index.js -- forger --config $HOME/.ark/config --network $2 > /dev/null 2>&1
    else
      echo "Forger already running!"
    fi
  else
    local status=$(pm2status "ark-core-$1" | awk '{print $13}')
    if [[ "$status" != "online" && "$2" = "mainnet" ]]; then
      pm2 --name "ark-core-$1" start $HOME/ark-core/packages/core/bin/ark -- $1 --config $HOME/.ark/config --network $2 > /dev/null 2>&1
    elif [[ "$status" != "online" && "$2" = "devnet" ]]; then
      pm2 --name "ark-core-$1" start $HOME/ark-core/packages/core/dist/index.js -- $1 --config $HOME/.ark/config --network $2 > /dev/null 2>&1
    else
      echo "Process already running!"
    fi
  fi
}

stop () {
  if [ "$1" = "all" ]; then
    local fstatus=$(pm2status "ark-core-forger" | awk '{print $13}')
    local rstatus=$(pm2status "ark-core-relay" | awk '{print $13}')
    if [ "$rstatus" = "online" ]; then
      pm2 stop ark-core-relay > /dev/null 2>&1
    else
      echo "Relay already stopped!"
    fi
    if [ "$fstatus" = "online" ]; then
      pm2 stop ark-core-forger > /dev/null 2>&1
    else
      echo "Forger already stopped!"
    fi
  else
    local status=$(pm2status "ark-core-$1" | awk '{print $13}')
    if [ "$status" = "online" ]; then
      pm2 stop ark-core-$1 > /dev/null 2>&1
    else
      echo "Process already stopped!"
    fi
  fi
}

install_deps () {
  sudo apt install -y htop curl build-essential python git nodejs npm libpq-dev ntp > /dev/null 2>&1
  sudo npm install -g n grunt-cli pm2 yarn > /dev/null 2>&1
  sudo n 10 > /dev/null 2>&1
}

install_db () {
  sudo apt install -y postgresql postgresql-contrib > /dev/null 2>&1
  sudo -u postgres psql -c "CREATE USER $USER WITH PASSWORD 'password' CREATEDB;" > /dev/null 2>&1
  dropdb ark_$1 > /dev/null 2>&1
  createdb ark_$1 > /dev/null 2>&1
}

install_core () {
  if [ "$1" = "mainnet" ]; then
    git clone https://github.com/ArkEcosystem/core.git $HOME/ark-core > /dev/null 2>&1
  else
    git clone https://github.com/ArkEcosystem/core.git $HOME/ark-core -b develop > /dev/null 2>&1
  fi
  cd $HOME/ark-core && yarn setup > /dev/null 2>&1
  mkdir $HOME/.ark > /dev/null 2>&1
  if [ "$1" = "mainnet" ]; then
    sudo npm -g install lerna > /dev/null 2>&1
    cd $HOME/ark-core > /dev/null 2>&1
    lerna clean -y > /dev/null 2>&1
    lerna bootstrap > /dev/null 2>&1
    cp -rf "$HOME/ark-core/packages/core/lib/config/$1" "$HOME/.ark/"
    cp "$HOME/ark-core/packages/crypto/lib/networks/ark/$1.json" "$HOME/.ark/$1/network.json"
  else
    cd $HOME/ark-core && yarn setup > /dev/null 2>&1
    cp -rf "$HOME/ark-core/packages/core/src/config/$1" "$HOME/.ark/"
  fi
  mv "$HOME/.ark/$1" "$HOME/.ark/config"
  local envFile="$HOME/.ark/.env"
  touch "$envFile"
  grep -q '^ARK_LOG_LEVEL' "$envFile" 2>&1 || echo "ARK_LOG_LEVEL=info" >> "$envFile" 2>&1
  grep -q '^ARK_DB_HOST' "$envFile" 2>&1 || echo "ARK_DB_HOST=localhost" >> "$envFile" 2>&1
  grep -q '^ARK_DB_PORT' "$envFile" 2>&1 || echo "ARK_DB_PORT=5432" >> "$envFile" 2>&1
  grep -q '^ARK_DB_USERNAME' "$envFile" 2>&1 || echo "ARK_DB_USERNAME=$USER" >> "$envFile" 2>&1
  grep -q '^ARK_DB_PASSWORD' "$envFile" 2>&1 || echo "ARK_DB_PASSWORD=password" >> "$envFile" 2>&1
  grep -q '^ARK_DB_DATABASE' "$envFile" 2>&1 || echo "ARK_DB_DATABASE=ark_$1" >> "$envFile" 2>&1
  grep -q '^ARK_P2P_HOST' "$envFile" 2>&1 || echo "ARK_P2P_HOST=0.0.0.0" >> "$envFile" 2>&1
  if [ "$1" = "mainnet" ]; then
    grep -q '^ARK_P2P_PORT' "$envFile" 2>&1 || echo "ARK_P2P_PORT=4001" >> "$envFile" 2>&1
  else
    grep -q '^ARK_P2P_PORT' "$envFile" 2>&1 || echo "ARK_P2P_PORT=4002" >> "$envFile" 2>&1
  fi
  grep -q '^ARK_API_HOST' "$envFile" 2>&1 || echo "ARK_API_HOST=0.0.0.0" >> "$envFile" 2>&1
  grep -q '^ARK_API_PORT' "$envFile" 2>&1 || echo "ARK_API_PORT=4003" >> "$envFile" 2>&1
  grep -q '^ARK_WEBHOOKS_HOST' "$envFile" 2>&1 || echo "ARK_WEBHOOKS_HOST=0.0.0.0" >> "$envFile" 2>&1
  grep -q '^ARK_WEBHOOKS_PORT' "$envFile" 2>&1 || echo "ARK_WEBHOOKS_PORT=4004" >> "$envFile" 2>&1
  grep -q '^ARK_GRAPHQL_HOST' "$envFile" 2>&1 || echo "ARK_GRAPHQL_HOST=0.0.0.0" >> "$envFile" 2>&1
  grep -q '^ARK_GRAPHQL_PORT' "$envFile" 2>&1 || echo "ARK_GRAPHQL_PORT=4005" >> "$envFile" 2>&1
  grep -q '^ARK_JSONRPC_HOST' "$envFile" 2>&1 || echo "ARK_JSONRPC_HOST=0.0.0.0" >> "$envFile" 2>&1
  grep -q '^ARK_JSONRPC_PORT' "$envFile" 2>&1 || echo "ARK_JSONRPC_PORT=8080" >> "$envFile" 2>&1
}

uninstall () {
  pm2 delete ark-core-forger ark-core-relay > /dev/null 2>&1
  rm -rf $HOME/ark-core && rm -rf $HOME/.ark > /dev/null 2>&1
  dropdb ark_$1 > /dev/null 2>&1
}
