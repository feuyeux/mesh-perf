#!/usr/bin/env sh
# shellcheck disable=SC2004 disable=SC2086 disable=SC2139 disable=SC2039 disable=SC2164 disable=SC2002
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
. ../config
alias k="kubectl --kubeconfig $USER_CONFIG"
alias m="kubectl --kubeconfig $MESH_CONFIG"

SEQUENCE=$1
NUM=$2
NS=$3
FILE=$4
VERSION=$5
DO_SVC=$6

DEPLOY_FILE=deploy_$FILE
SVC_FILE=svc_$FILE

write_service() {
    cat ../resources/kube_service.yaml |
        sed "s#CUR_SVC#hello-svc$SEQUENCE#g" |
        sed "s#POD#hello$SEQUENCE#g" >>$SVC_FILE
}

write_line1() {
    printf "\n" >>$SVC_FILE
    echo "---" >>$SVC_FILE
}

write_line2() {
    printf "\n" >>$DEPLOY_FILE
    echo "---" >>$DEPLOY_FILE
}

write_last_pod() {
    cat ../resources/kube_deployment.yaml | sed "/env/d" |
        sed "/HTTP_HELLO_BACKEND/d" |
        sed "/NEXT_SVC/d" |
        sed "s#NS#$NS#g" |
        sed "s#POD#hello$SEQUENCE#g" |
        sed "s#VERSION#$VERSION#g" |
        sed "s#PAYLOAD#hello$SEQUENCE$VERSION#g" >>$DEPLOY_FILE
}

write_pod() {
    ((next = $SEQUENCE + 1))
    cat ../resources/kube_deployment.yaml |
        sed "s#NEXT_SVC#hello-svc$next#g" |
        sed "s#NS#$NS#g" |
        sed "s#POD#hello$SEQUENCE#g" |
        sed "s#VERSION#$VERSION#g" |
        sed "s#PAYLOAD#hello$SEQUENCE$VERSION#g" >>$DEPLOY_FILE
}

if [ "$SEQUENCE" = "$NUM" ]; then
    if [ "$DO_SVC" = "Y" ]; then
        write_service
        echo "kubectl apply -n $NS -f $SVC_FILE"
        k apply -n $NS -f $SVC_FILE
    fi
    write_last_pod
    echo "kubectl apply -n $NS -f $DEPLOY_FILE"
    k apply -n $NS -f $DEPLOY_FILE
else
    if [ "$DO_SVC" = "Y" ]; then
        write_service
        write_line1
    fi
    write_pod
    write_line2
fi
