#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

"${CURRENT_DIR}"/cheapest-aws-gpu-spot-instance/cheapest-aws-gpu-spot-instance.deps.pex    \
    "${CURRENT_DIR}"/cheapest-aws-gpu-spot-instance/cheapest-aws-gpu-spot-instance.py "${@}"

#--aws-access-key=AKIAJCBSNX3UNPTGZTVQ --aws-secret-key=LTV0uQ7SIVXBN1OTb/9GUX2syBc1vNQtqc3E2p1Raaa
