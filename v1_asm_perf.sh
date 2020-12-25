#!/usr/bin/env sh
# shellcheck disable=SC2004 disable=SC2086 disable=SC2139 disable=SC2039

SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH/scripts" || exit

. ../config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"
KUBE_FILE=batch_kube.yaml
MESH_FILE=batch_mesh.yaml
SVC_FILE=svc_$KUBE_FILE
DEPLOY_FILE=deploy_$KUBE_FILE

clean() {
    echo "cleaning testing environment..."
    k delete namespace $NS >/dev/null 2>&1
    m delete namespace $NS >/dev/null 2>&1
    sleep 15
}

init() {
    clean
    echo "creating testing environment..."
    k create ns $NS
    k label ns $NS istio-injection=enabled
    m create ns $NS
    m label ns $NS istio-injection=enabled
    sleep 2.5
}

init

set -e
echo "init done"
echo "" >$SVC_FILE
echo "" >$DEPLOY_FILE
echo "" >$MESH_FILE

for ((i = 1; i <= ${LOOP}; i++)); do
    sh kube_request.sh ${i} $LOOP ${NS} $KUBE_FILE v1 Y
    sh mesh_request.sh ${i} $LOOP ${NS} $MESH_FILE v1
done
rm -rf $SVC_FILE $DEPLOY_FILE $MESH_FILE
sleep 30
sh ../curl_asm_perf.sh v1
