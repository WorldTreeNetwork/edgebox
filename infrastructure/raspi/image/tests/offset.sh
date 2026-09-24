#!/usr/bin/env bash
# Prove partition mount and grow without a kernel MBR parser.
set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
IMAGE_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)
# shellcheck source=../lib/common.sh
source "$IMAGE_DIR/lib/common.sh"
# shellcheck source=../lib/image.sh
source "$IMAGE_DIR/lib/image.sh"

if [[ $(uname -s) != Linux ]]; then
  log "offset test requires Linux"
  exit 0
fi
if [[ $(id -u) -ne 0 ]]; then
  log "offset test requires root"
  exit 0
fi
for cmd in sfdisk losetup mkfs.ext4 mkfs.vfat blockdev; do
  require_command "$cmd"
done

WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/edgebox-offset.XXXXXX")
trap 'detach_image; rm -rf "$WORK_DIR"' EXIT

img=$WORK_DIR/disk.img
truncate -s 64M "$img"
sfdisk "$img" <<'EOF'
label: dos
,16M,c
,,83
EOF

IMAGE_BOOT_LOOP=$(open_partition_loop "$img" 1)
IMAGE_LOOP=$(open_partition_loop "$img" 2)
mkfs.vfat -n BOOT "$IMAGE_BOOT_LOOP" >/dev/null
mkfs.ext4 -F -L rootfs "$IMAGE_LOOP" >/dev/null
mkdir -p "$WORK_DIR/probe"
mount "$IMAGE_LOOP" "$WORK_DIR/probe"
printf 'edgebox-offset\n' > "$WORK_DIR/probe/marker"
before=$(blockdev --getsize64 "$IMAGE_LOOP")
umount "$WORK_DIR/probe"
losetup -d "$IMAGE_BOOT_LOOP"
losetup -d "$IMAGE_LOOP"
IMAGE_BOOT_LOOP=
IMAGE_LOOP=

grow_image "$img" 16
attach_image "$img" "$WORK_DIR/mnt"
[[ $(<"$IMAGE_ROOT_MOUNT/marker") == edgebox-offset ]]
after=$(blockdev --getsize64 "$IMAGE_LOOP")
[[ "$after" -gt "$before" ]]
mountpoint -q "$IMAGE_BOOT_MOUNT"
log "offset partition test passed (${before} -> ${after} bytes)"
detach_image
trap - EXIT
rm -rf "$WORK_DIR"
