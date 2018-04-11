#!/bin/sh

#docker run -it ubuntu:16.04 /bin/bash

#sudo apt-get update
#sudo apt-get install --no-install-recommends python3 python3-pip build-essential python3-dev
#sudo pip install pex

pex boto3 numpy -o cheapest-aws-gpu-spot-instance.deps.pex -vvvv

#docker cp instance-id:/cheapest-aws-gpu-spot-instance.deps.pex .
