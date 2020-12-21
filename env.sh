#!/usr/bin/env bash
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source config
alias k="kubectl --kubeconfig $USER_CONFIG"

hello1_pod=$(k get po -l app=hello1 -n $NS | awk '{print $1}' | awk 'NR==2{print}')
k exec $hello1_pod -n $NS -c hello1-deploy -- env