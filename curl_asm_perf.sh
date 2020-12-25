#!/usr/bin/env sh
# shellcheck disable=SC2004 disable=SC2086 disable=SC2139 disable=SC2039 disable=SC2164
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH"
source config
TEST_LOOP=3

alias k="kubectl --kubeconfig $USER_CONFIG"
ingress_gateway=$(k get svc/istio-ingressgateway -n istio-system | awk '{print $4}' | awk 'NR==2{print}')
echo "ingress_gateway ip:$ingress_gateway"
mkdir /tmp/asm_perf/ >/dev/null 2>&1

request() {
    code=$(curl -s -w "%{http_code}" -H "Host:$2-$1.aliyun.com" "http://$ingress_gateway:8001/hello/eric" -o /tmp/asm_perf/result${1})
    echo "${code} $(count /tmp/asm_perf/result${1})"
}

count() {
    sed -i "" "s/</\n/g" $1
    awk 'END{print NR}' $1
}

echo "curl -s -H \"Host:$1-1.aliyun.com\" \"http://$ingress_gateway:8001/hello/eric\"" 
curl -s -H "Host:$1-1.aliyun.com" "http://$ingress_gateway:8001/hello/eric" 
for ((i = 1; i <= ${TEST_LOOP}; i++)); do
    test_result=$(request $i $1)
    ((expected_count = ${LOOP} - ${i} + 1))
    if [[ "$test_result" == "200 $expected_count" ]]; then
        echo "pass"
    else
        echo "fail"
    fi
done
