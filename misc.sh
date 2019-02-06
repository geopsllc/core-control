#!/bin/bash

i=1
sp="/-\|"

als="$(cat $HOME/.bashrc | grep ccontrol)"
ccc="$(cat $HOME/.bashrc | grep cccomp)"

if [ -z "$als" ]; then
  echo "alias ccontrol=$PWD/ccontrol.sh" >> $HOME/.bashrc
fi

if [ -z "$ccc" ]; then
  echo "source $PWD/cccomp.bash" >> $HOME/.bashrc
fi
