#!/usr/bin/env bash

load_env_file() {
  local file=${1:?configuration file required}
  [[ -r "$file" ]] || die "configuration file is not readable: $file"
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    [[ "$key" =~ ^[A-Z][A-Z0-9_]*$ ]] || die "invalid configuration key in $file: $key"
    printf -v "$key" '%s' "$value"
    # shellcheck disable=SC2163 # Export the validated dynamic key, not the local variable named key.
    export "$key"
  done < "$file"
}

validate_site_file() {
  local file=${1:?site configuration required}
  local key _value
  while IFS='=' read -r key _value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    case "$key" in
      EDGEBOX_HOSTNAME|EDGEBOX_USER|EDGEBOX_TIMEZONE|EDGEBOX_LOCALE|EDGEBOX_KEYMAP|\
      EDGEBOX_LAN_INTERFACE|EDGEBOX_NETWORK_MODE|EDGEBOX_LAN_ADDRESS|EDGEBOX_LAN_GATEWAY|\
      EDGEBOX_LAN_DNS|EDGEBOX_LOCAL_DOMAIN|EDGEBOX_PROFILES|EDGEBOX_DATA_MOUNT|\
      EDGEBOX_DATA_UUID|EDGEBOX_PXE_MODE|EDGEBOX_PXE_DHCP_START|EDGEBOX_PXE_DHCP_END|\
      EDGEBOX_PXE_NETMASK|EDGEBOX_PXE_GATEWAY|EDGEBOX_PXE_DNS|\
      EDGEBOX_ACKNOWLEDGE_DHCP_SERVER|EDGEBOX_SSH_PUBLIC_KEY) ;;
      *) die "unsupported or unsafe site configuration key: $key" ;;
    esac
  done < "$file"
}

validate_config() {
  [[ "${EDGEBOX_HOSTNAME:-}" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$ ]] || die "invalid EDGEBOX_HOSTNAME"
  [[ "${EDGEBOX_USER:-}" =~ ^[a-z_][a-z0-9_-]{0,30}$ ]] || die "invalid EDGEBOX_USER"
  [[ "${EDGEBOX_NETWORK_MODE:-}" == dhcp || "${EDGEBOX_NETWORK_MODE:-}" == static ]] || die "EDGEBOX_NETWORK_MODE must be dhcp or static"
  if [[ "$EDGEBOX_NETWORK_MODE" == static ]]; then
    [[ -n "${EDGEBOX_LAN_ADDRESS:-}" && -n "${EDGEBOX_LAN_GATEWAY:-}" && -n "${EDGEBOX_LAN_DNS:-}" ]] || die "static networking requires address, gateway, and DNS"
  fi
  case "${EDGEBOX_PXE_MODE:-disabled}" in
    disabled|tftp-only|proxy) ;;
    authoritative)
      is_true "${EDGEBOX_ACKNOWLEDGE_DHCP_SERVER:-false}" || die "authoritative PXE requires EDGEBOX_ACKNOWLEDGE_DHCP_SERVER=true"
      [[ -n "${EDGEBOX_PXE_DHCP_START:-}" && -n "${EDGEBOX_PXE_DHCP_END:-}" && -n "${EDGEBOX_PXE_NETMASK:-}" ]] || die "authoritative PXE requires a complete DHCP range"
      ;;
    *) die "invalid EDGEBOX_PXE_MODE" ;;
  esac
  [[ -n "${EDGEBOX_SSH_PUBLIC_KEY:-}" && "$EDGEBOX_SSH_PUBLIC_KEY" != *REPLACE_ME* ]] || die "a real EDGEBOX_SSH_PUBLIC_KEY is required"
}

profile_enabled() {
  local wanted=${1:?profile required}
  local profiles=",${EDGEBOX_PROFILES// /},"
  [[ "$profiles" == *",$wanted,"* ]]
}
