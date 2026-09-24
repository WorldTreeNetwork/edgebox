#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${1:-} == --dry-run ]] && DRY_RUN=true
source "$IMAGE_DIR/lib/common.sh"
source "$IMAGE_DIR/lib/image.sh"

if is_true "${DRY_RUN:-false}"; then log "would remove unique identities, caches, and logs, then unmount"; exit 0; fi
require_root
root_mount=$(<"$WORK_DIR/root-mount.path")
IMAGE_ROOT_MOUNT=$root_mount
IMAGE_BOOT_MOUNT=$(<"$WORK_DIR/boot-mount.path")
IMAGE_LOOP=$(<"$WORK_DIR/loop.path")
rm -f "$root_mount/etc/ssh/ssh_host_"* "$root_mount/etc/machine-id"
: > "$root_mount/etc/machine-id"
rm -rf "$root_mount/var/lib/systemd/random-seed" "$root_mount/var/cache/apt/archives/"*.deb
find "$root_mount/var/log" -type f -exec truncate -s 0 {} +
sync
detach_image
rm -f "$WORK_DIR/loop.path"
