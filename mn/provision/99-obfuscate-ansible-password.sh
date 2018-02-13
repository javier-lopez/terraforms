#!/bin/sh

passwd="$(strings /dev/urandom | grep -o '[0-9a-Z_./~:,;()!?%*#$%&+=@-]' | \
          head -n "50" | tr -d '\n' 2>/dev/null)"

printf "%s\\n" "ansible:${passwd}" | chpasswd

printf "%s\\n" "${passwd}"
