#!/bin/bash

i=1
sp="/-\|"

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
magenta='\033[0;35m'
cyan='\033[0;36m'
nc='\033[0m'


als="$(cat $HOME/.bashrc | grep ccontrol)"
ccc="$(cat $HOME/.bashrc | grep cccomp)"
aln="$(cat $HOME/.bashrc | grep $name)"

if [ -z "$als" ]; then
  echo "alias ccontrol=$PWD/ccontrol.sh" >> $HOME/.bashrc
fi

if [ -z "$aln" ]; then
  echo "alias ${name}=$core/packages/core/bin/run" >> $HOME/.bashrc
fi

if [ -z "$ccc" ]; then
  echo "source $PWD/cccomp.bash" >> $HOME/.bashrc
fi

if [ -f "$core/packages/core/package.json" ]; then
  corever=$(cat $core/packages/core/package.json | jq -r '.version')
fi
