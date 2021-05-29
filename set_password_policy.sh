#!/usr/bin/env bash

# Author: suporte3@dati.com.br
# Set default IAM password policy

# IMPORT SHARED FUNCTIONS
source shared_functions.sh

# VARS

# FUNCTIONS
set_password_policy() {
 aws iam update-account-password-policy \
    --minimum-password-length 10 \
    --require-symbols \
    --require-numbers \
    --require-uppercase-characters \
    --require-lowercase-characters \
    --allow-users-to-change-password \
    --max-password-age 90 \
    --password-reuse-prevention 5
}

# MAIN
request_confirmation "Changing the password policy"
set_password_policy
