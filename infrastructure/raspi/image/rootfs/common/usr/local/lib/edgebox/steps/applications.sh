#!/usr/bin/env bash
set -Eeuo pipefail
source /usr/local/lib/edgebox/common.sh

profile_enabled apps || exit 0
bind_address=${EDGEBOX_LAN_ADDRESS%/*}
if [[ -z "$bind_address" ]]; then
  bind_address=$(ip -4 -o address show dev "$EDGEBOX_LAN_INTERFACE" scope global | awk 'NR==1 {split($4,a,"/"); print a[1]}')
fi
[[ -n "$bind_address" ]] || die "unable to determine application bind address"

stack_dir=/home/$EDGEBOX_USER/services/edgebox
install -d -m 0750 -o "$EDGEBOX_USER" -g "$EDGEBOX_USER" "$stack_dir"
rsync -a /usr/local/share/edgebox/compose.yaml "$stack_dir/compose.yaml"
printf 'EDGEBOX_BIND_ADDRESS=%s\n' "$bind_address" > "$stack_dir/.env"
chown -R "$EDGEBOX_USER:$EDGEBOX_USER" "$stack_dir"
sudo -u "$EDGEBOX_USER" docker compose -f "$stack_dir/compose.yaml" config --quiet
sudo -u "$EDGEBOX_USER" docker compose -f "$stack_dir/compose.yaml" pull
sudo -u "$EDGEBOX_USER" docker compose -f "$stack_dir/compose.yaml" up -d
