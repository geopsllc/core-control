#!/bin/bash

i=1
sp="/-\|"

als="$(cat $HOME/.bashrc | grep ccontrol)"

if [ -z "$als" ]; then
  echo "alias ccontrol=$PWD/ccontrol.sh" >> $HOME/.bashrc
fi

if [ -f $data/.env ]; then
  network="$(cat $data/devnet/.env | grep DATA | awk -F"_" '{print $4}')"
fi
