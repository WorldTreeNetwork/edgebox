#!/usr/bin/env bash
set -Eeuo pipefail
source /usr/local/lib/edgebox/common.sh

# Docker-published ports bypass ordinary ufw rules. Limit traffic entering
# published IPv4 ports to the directly connected LAN. Compose also binds the
# applications to the selected LAN address rather than 0.0.0.0.
lan_subnet=$(ip -4 route show dev "$EDGEBOX_LAN_INTERFACE" proto kernel scope link | awk 'NR==1 {print $1}')
[[ -n "$lan_subnet" ]] || die "unable to determine LAN subnet for Docker firewall"

iptables -N EDGEBOX-LAN 2>/dev/null || true
iptables -F EDGEBOX-LAN
iptables -A EDGEBOX-LAN -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A EDGEBOX-LAN -s "$lan_subnet" -j ACCEPT
iptables -A EDGEBOX-LAN -j DROP
iptables -C DOCKER-USER -i "$EDGEBOX_LAN_INTERFACE" -j EDGEBOX-LAN 2>/dev/null || \
  iptables -I DOCKER-USER 1 -i "$EDGEBOX_LAN_INTERFACE" -j EDGEBOX-LAN

mkdir -p /etc/iptables
iptables-save > /etc/iptables/rules.v4
cat > /etc/systemd/system/edgebox-firewall.service <<'EOF'
[Unit]
Description=Restore Edgebox Docker ingress policy
After=docker.service
Before=edgebox-first-boot.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/iptables-restore /etc/iptables/rules.v4
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable edgebox-firewall.service
