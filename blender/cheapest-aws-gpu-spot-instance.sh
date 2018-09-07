#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

"${CURRENT_DIR}"/provision/cheapest-aws-gpu-spot-instance.deps.pex \
    "${CURRENT_DIR}"/provision/cheapest-aws-gpu-spot-instance.py "${@}"
