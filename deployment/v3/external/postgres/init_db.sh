#!/bin/bash
# Script to initialize the DB. 
## Usage: ./init_db.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

function initialize_db() {
  NS=postgres
  CHART_VERSION=12.0.1-prod
  helm repo add nira https://niragit.github.io/mosip-helm
  helm repo update

  while true; do
      read -p "CAUTION: all existing data will be lost. Are you sure?(Y/n)" yn
      if [ $yn = "Y" ]
        then
          echo Removing any existing installation
          helm -n $NS delete postgres-init || true
          echo Initializing DB
          helm -n $NS install postgres-init nira/postgres-init -f init_values.yaml --set-string nodeSelector.vlan="200" --version $CHART_VERSION --wait --wait-for-jobs
          break
        else
          break
      fi
  done
  return 0
}

# set commands for error handling.
set -e
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errtrace  # trace ERR through 'time command' and other functions
set -o pipefail  # trace ERR through pipes
initialize_db   # calling function
