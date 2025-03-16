#!/bin/bash
# Creates configmap and secrets for SMTP and SMS
## Usage: ./install.sh [kubeconfig]

if [ $# -ge 1 ] ; then
  export KUBECONFIG=$1
fi

NS=msg-gateways

echo Create $NS namespace
kubectl create ns $NS

function msg_gateway() {
  echo Istio label
  kubectl label ns $NS istio-injection=enabled --overwrite

  SMTP_HOST=mock-smtp.mock-smtp
  SMS_HOST=mock-smtp.mock-smtp
  SMTP_PORT=8025
  SMS_PORT=8080
  SMTP_USER=
  SMS_USER=
  SMTP_SECRET="''"
  SMS_SECRET="''"
  SMS_AUTHKEY="authkey"

  read -p "Would you like to use mock-smtp (Y/N) [ Default: Y ] : " yn
  # Set yn to N if user input is null
  if [ -z $yn ]; then
    yn=Y;
  fi
  if [ $yn != "Y" ]; then
      read -p "Please enter the SMTP host " SMTP_HOST
      read -p "Please enter the SMTP host port " SMTP_PORT
      read -p "Please enter the SMTP user " SMTP_USER
      read -p "Please enter the SMTP secret key " SMTP_SECRET
  fi
  unset yn
  read -p "Would you like to use mock-sms (Y/N) [ Default: Y ] : " yn
  if [ -z $yn ]; then
    yn=Y;
  fi
  if [ $yn != "Y" ]; then
      read -p "Please enter the SMS host url    " SMS_HOST_URL
      read -p "Please enter the SMS user id     " SMS_USER_ID
      read -p "Please enter the SMS secret key  " SMS_SECRET
      read -p "Please enter the SMS auth key    " SMS_AUTHKEY
      read -p "Please enter the SMS EMAIL ID    " SMS_EMAIL_ID
  fi

  kubectl -n $NS delete --ignore-not-found=true configmap msg-gateway
  kubectl -n $NS create configmap msg-gateway  --from-literal="sms-host-url=$SMS_HOST_URL" --from-literal="smtp-host=$SMTP_HOST" --from-literal="smtp-port=$SMTP_PORT" --from-literal="smtp-username=$SMTP_USER"

  kubectl -n $NS delete --ignore-not-found=true secret msg-gateway
  kubectl -n $NS create secret generic msg-gateway  --from-literal="sms-email-id=$SMS_EMAIL_ID" --from-literal="sms-user-id=$SMS_USER_ID"  --from-literal="sms-secret=$SMS_SECRET" --from-literal="sms-authkey=$SMS_AUTHKEY" --from-literal="smtp-secret=$SMTP_SECRET" --dry-run=client  -o yaml | kubectl apply -f -

  echo smtp and sms related configurations set.
  return 0
}

# set commands for error handling.
set -e
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errtrace  # trace ERR through 'time command' and other functions
set -o pipefail  # trace ERR through pipes
msg_gateway   # calling function
