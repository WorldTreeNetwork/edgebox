#!/usr/bin/env bash
set -Eeuo pipefail
source /usr/local/lib/edgebox/common.sh

profile_enabled pxe || { systemctl disable --now dnsmasq 2>/dev/null || true; exit 0; }
[[ "$EDGEBOX_PXE_MODE" != disabled ]] || exit 0
[[ -f /srv/tftp/ipxe.efi ]] || die "PXE profile selected but /srv/tftp/ipxe.efi is absent"

install -d -m 0755 /etc/dnsmasq.d
{
  printf 'interface=%s\n' "$EDGEBOX_LAN_INTERFACE"
  printf 'bind-interfaces\nlog-dhcp\nenable-tftp\ntftp-root=/srv/tftp\ndhcp-boot=ipxe.efi\n'
  case "$EDGEBOX_PXE_MODE" in
    proxy) printf 'dhcp-range=%s,proxy\n' "${EDGEBOX_LAN_ADDRESS%/*}" ;;
    authoritative)
      printf 'dhcp-range=%s,%s,%s,1h\n' "$EDGEBOX_PXE_DHCP_START" "$EDGEBOX_PXE_DHCP_END" "$EDGEBOX_PXE_NETMASK"
      printf 'dhcp-option=3,%s\ndhcp-option=6,%s\n' "$EDGEBOX_PXE_GATEWAY" "$EDGEBOX_PXE_DNS"
      ;;
  esac
} > /etc/dnsmasq.d/edgebox-pxe.conf
dnsmasq --test
caddy validate --config /etc/caddy/Caddyfile
systemctl enable --now dnsmasq caddy
