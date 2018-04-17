#!/bin/sh

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd)"

"${CURRENT_DIR}"/scripts/cheapest-aws-gpu-spot-instance.deps.pex \
    "${CURRENT_DIR}"/scripts/cheapest-aws-gpu-spot-instance.py "${@}"
