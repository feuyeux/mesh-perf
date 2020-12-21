#!/usr/bin/env sh
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source ../config
alias m="kubectl --kubeconfig $MESH_CONFIG"

SEQUENCE=$1
NUM=$2
NS=$3
FILE=$4
VERSION=$5

write_gateway() {
    if [[ "$VERSION" == v1 ]]; then
        GW_FILE=../resources/mesh_gateway_1.yaml
    else
        GW_FILE=../resources/mesh_gateway_2.yaml
    fi
    cat $GW_FILE |
        sed "s#GW#hello-gw$SEQUENCE#g" |
        sed "s#*#$VERSION-$SEQUENCE.aliyun.com#g" |
        sed "s#%#v1-$SEQUENCE.aliyun.com#g" >>$FILE
}

write_virtualservice() {
    if [[ "$VERSION" == v1 ]]; then
        VS_FILE=../resources/mesh_virtualservice_1.yaml
    else
        VS_FILE=../resources/mesh_virtualservice_2.yaml
    fi
    cat $VS_FILE |
        sed "s#GW#hello-gw$SEQUENCE#g" |
        sed "s#*#$VERSION-$SEQUENCE.aliyun.com#g" |
        sed "s#%#v1-$SEQUENCE.aliyun.com#g" |
        sed "s#CUR_SVC#hello-svc$SEQUENCE#g" |
        sed "s#CUR_VS#hello-vs$SEQUENCE#g" |
        sed "s#VERSION#$VERSION#g" |
        sed "s#PREVIOUS#v1#g" >>$FILE
}

write_destionationrule() {
    cat ../resources/mesh_destinationrule.yaml |
        sed "s#CUR_DR#hello-dr$SEQUENCE#g" |
        sed "s#CUR_SVC#hello-svc$SEQUENCE#g" >>$FILE
}

write_line() {
    echo "\n" >>$FILE
    echo "---" >>$FILE
}

if [ "$SEQUENCE" = "$NUM" ]; then
    write_gateway
    write_line
    write_virtualservice
    write_line
    write_destionationrule
    echo "kubectl apply -n $NS -f $FILE"
    m apply -n $NS -f $FILE
else
    write_gateway
    write_gateway
    write_line
    write_virtualservice
    write_line
    write_destionationrule
    write_line
fi
