#!/bin/bash

i=1
sp="/-\|"

als="$(cat $HOME/.bashrc | grep ccontrol)"

if [ -z "$als" ]; then
  echo "alias ccontrol=$PWD/ccontrol.sh" >> $HOME/.bashrc
fi
