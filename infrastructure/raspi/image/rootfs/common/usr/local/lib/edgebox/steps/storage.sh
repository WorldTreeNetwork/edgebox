#!/usr/bin/env bash
set -Eeuo pipefail
source /usr/local/lib/edgebox/common.sh

[[ -n "${EDGEBOX_DATA_UUID:-}" ]] || exit 0
device=/dev/disk/by-uuid/$EDGEBOX_DATA_UUID
[[ -b "$device" ]] || die "configured data filesystem not found: $EDGEBOX_DATA_UUID"
fstype=$(blkid -s TYPE -o value "$device")
[[ -n "$fstype" ]] || die "unable to detect filesystem type for $device"
mkdir -p "$EDGEBOX_DATA_MOUNT"
if ! grep -q "^UUID=$EDGEBOX_DATA_UUID " /etc/fstab; then
  printf 'UUID=%s %s %s defaults,nofail,x-systemd.device-timeout=10 0 2\n' \
    "$EDGEBOX_DATA_UUID" "$EDGEBOX_DATA_MOUNT" "$fstype" >> /etc/fstab
fi
mount "$EDGEBOX_DATA_MOUNT"
