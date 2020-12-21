#!/usr/bin/env sh
# shellcheck disable=SC2004 disable=SC2086 disable=SC2139 disable=SC2039
set -e
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH/batch_scripts" || exit

source ../config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"
KUBE_FILE=batch_kube.yaml
MESH_FILE=batch_mesh.yaml
SVC_FILE=svc_$KUBE_FILE
DEPLOY_FILE=deploy_$KUBE_FILE

echo "" >$SVC_FILE
echo "" >$DEPLOY_FILE
echo "" >$MESH_FILE
for ((i = 1; i <= ${LOOP}; i++)); do
    sh kube_request.sh ${i} ${LOOP} ${NS} $KUBE_FILE v2 N
    sh mesh_request.sh ${i} ${LOOP} ${NS} $MESH_FILE v2
done
rm -rf $DEPLOY_FILE $MESH_FILE
sh ../curl_asm_perf.sh v2