#!/usr/bin/env bash
set -Eeuo pipefail
source /usr/local/lib/edgebox/common.sh

if [[ "$EDGEBOX_NETWORK_MODE" == static ]]; then
  connection=$(nmcli -g GENERAL.CONNECTION device show "$EDGEBOX_LAN_INTERFACE")
  [[ -n "$connection" && "$connection" != -- ]] || die "no NetworkManager connection for $EDGEBOX_LAN_INTERFACE"
  nmcli connection modify "$connection" \
    ipv4.method manual \
    ipv4.addresses "$EDGEBOX_LAN_ADDRESS" \
    ipv4.gateway "$EDGEBOX_LAN_GATEWAY" \
    ipv4.dns "$EDGEBOX_LAN_DNS"
  nmcli connection reload
fi
