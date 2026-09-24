#!/usr/bin/env bash
set -Eeuo pipefail
source /usr/local/lib/edgebox/common.sh

systemctl is-active --quiet ssh docker
docker info >/dev/null
if [[ -f /sys/fs/cgroup/cgroup.controllers ]]; then
  grep -qw memory /sys/fs/cgroup/cgroup.controllers || die "memory cgroup controller is unavailable"
else
  awk '$1 == "memory" && $4 == 1 {found=1} END {exit !found}' /proc/cgroups || die "memory cgroup controller is unavailable"
fi
if profile_enabled apps; then
  stack_dir=/home/$EDGEBOX_USER/services/edgebox
  [[ $(docker compose -f "$stack_dir/compose.yaml" ps --status running --quiet | wc -l) -eq 4 ]] || die "not all application containers are running"
  bind_address=$(<"$stack_dir/.env")
  bind_address=${bind_address#EDGEBOX_BIND_ADDRESS=}
  for port in 3000 8222 3456 8082; do
    ready=false
    for _attempt in 1 2 3 4 5 6 7 8 9 10 11 12; do
      if curl -fsS --connect-timeout 2 --max-time 10 "http://$bind_address:$port/" >/dev/null; then ready=true; break; fi
      sleep 5
    done
    [[ "$ready" == true ]] || die "application on port $port did not become ready"
  done
fi
if profile_enabled pxe && [[ "$EDGEBOX_PXE_MODE" != disabled ]]; then
  systemctl is-active --quiet dnsmasq caddy
fi
