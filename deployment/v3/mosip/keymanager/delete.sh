#!/bin/sh
# Uninstalls Keymanager
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=keymanager
while true; do
    read -p "Are you sure you want to delete keymanager helm chart?(Y/n) " yn
    if [ $yn = "Y" ]
      then
        helm -n $NS delete keymanager
        helm -n $NS delete kernel-keygen
        break
      else
        break
    fi
done
