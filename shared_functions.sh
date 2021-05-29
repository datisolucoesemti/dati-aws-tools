#!/usr/bin/env bash


# VARS

# FUNCTIONS
get_account_alias() {
  aws iam list-account-aliases --output text | awk '{print $2}'
}

get_account_id() {
  aws sts get-caller-identity --output text --query 'Account'
}

request_confirmation() {
  local REPLY
  local TEXT

  REPLY="n"
  TEXT="${1}"
  echo -ne "${TEXT}\n"
  echo ""
  echo "You are about to make this changes on account \"${ACCOUNT_ALIAS} (${ACCOUNT_ID})\""
  echo -ne "Do you want to proceed? (n/y): "
  read -r REPLY
  if [ ! "$REPLY" == "y" ]
  then
    echo "Canceling..."
    exit 1
  fi
}



# run function
#get_account_alias
#request_confirmation "foo bar ad eternum"


# MAIN
ACCOUNT_ID="$(get_account_id)"
ACCOUNT_ALIAS="$(get_account_alias)"
mkdir -p ${ACCOUNT_ID}
