#!/bin/bash
set -eu

set KFK_PID
PUBLIC_IF=${PUBLIC_IF:-eth0}
REPLICATION_IF=${REPLICATION_IF:-eth1}
ZK_CLUSTER=${ZK_CLUSTER:-127.0.0.1:2181}
KFK_CONFIG_SRC='/opt/kafka/config/server.properties'
KFK_CONFIG='/opt/kafka/config-var/server.properties'


function get_if_ip() {
    if [[ ${1} == eth[0-9] ]]; then
        ip addr show dev ${1} | pcregrep -oi 'inet \K[\d\.]+'
    else
        echo "ERROR: Missing or wrong interface name: ${1}"
        return 1
    fi
}

#function detokenize(){
#        sed -i -e "s/%@${1}@%/${!1}/g" ${2}
#}

function configure_kafka(){
    local PUBLIC_IP
    local REPLICATION_IP

    PUBLIC_IP=$(get_if_ip ${PUBLIC_IF})
    REPLICATION_IP=$(get_if_ip ${REPLICATION_IF})

    cp -v ${KFK_CONFIG_SRC} ${KFK_CONFIG}
    for token in PUBLIC_IP REPLICATION_IP ZK_CLUSTER BROKER_ID; do
        sed -i -e "s/%@${token}@%/${!token}/g" ${KFK_CONFIG}
    done
}

function start_kafka(){

    configure_kafka

    /opt/kafka/bin/kafka-server-start.sh ${KFK_CONFIG} &
    KFK_PID=$!
}

function stop_kafka(){
    kill $KFK_PID
}

trap stop_kafka SIGTERM SIGINT
start_kafka
wait

