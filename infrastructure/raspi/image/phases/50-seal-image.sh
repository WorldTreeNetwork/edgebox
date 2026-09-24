#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${1:-} == --dry-run ]] && DRY_RUN=true
source "$IMAGE_DIR/lib/common.sh"
source "$IMAGE_DIR/lib/image.sh"

if is_true "${DRY_RUN:-false}"; then log "would remove unique identities, caches, and logs, then unmount"; exit 0; fi
require_root
load_attach
root_mount=$IMAGE_ROOT_MOUNT
[[ -n "$root_mount" && -d "$root_mount" ]] || die "root mount is not recorded"
rm -f "$root_mount/etc/ssh/ssh_host_"* "$root_mount/etc/machine-id"
: > "$root_mount/etc/machine-id"
rm -rf "$root_mount/var/lib/systemd/random-seed" "$root_mount/var/cache/apt/archives/"*.deb
find "$root_mount/var/log" -type f -exec truncate -s 0 {} +
sync
detach_image
rm -f "$WORK_DIR/loop.path" "$WORK_DIR/boot-loop.path" "$WORK_DIR/root-mount.path" "$WORK_DIR/boot-mount.path"
