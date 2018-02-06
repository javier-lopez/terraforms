#!/bin/sh
set -xe

if ! command -v "docker" >/dev/null 2>&1; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    apt-get install -y software-properties-common apt-transport-https
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get -y update
    apt-get install -y docker-ce
fi

#don't require sudo to run docker
usermod -aG docker ${USER} || :
docker -v

#workaround to force vagrant to reconnect and allow the vagrant user to use docker
#ps aux | grep 'sshd:' | awk '{print $2}' | xargs kill
