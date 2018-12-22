#!/bin/bash

if [[ -d $HOME/.ark || -d $HOME/ark-core ]]; then
  echo "Core already installed. Please uninstall first."
  exit 1
fi



echo "out of loop"
