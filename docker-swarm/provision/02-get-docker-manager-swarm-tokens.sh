#!/bin/sh
#set -x #output debugging info, breaks terraform, investigate why
set -e  #exit on error

if ! command -v "jq" >/dev/null 2>&1; then
    sudo apt-get -y update
    sudo apt-get install -y jq
fi

#extract input variables
eval "$(jq -r '@sh "HOST=\(.host)"')"

#get worker join token
SSH_ARGS="-F /dev/null -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no"
WORKER="$(ssh  ${SSH_ARGS} "root@${HOST}" docker swarm join-token worker  -q)"
MANAGER="$(ssh ${SSH_ARGS} "root@${HOST}" docker swarm join-token manager -q)"

#pass back a JSON object
jq -n --arg worker "${WORKER}" --arg manager "${MANAGER}" '{"worker":$worker,"manager":$manager}'
