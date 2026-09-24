#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${1:-} == --dry-run ]] && DRY_RUN=true
source "$IMAGE_DIR/lib/common.sh"
source "$IMAGE_DIR/lib/image.sh"

WORK_IMAGE=$WORK_DIR/edgebox.raw.img
export WORK_IMAGE
if is_true "${DRY_RUN:-false}"; then
  log "would decompress the verified base, add ${EXTRA_ROOT_MIB} MiB, and mount its partitions"
  exit 0
fi
require_root
BASE_ARCHIVE=$(<"$WORK_DIR/base-archive.path")
xz --decompress --stdout "$BASE_ARCHIVE" > "$WORK_IMAGE"
grow_image "$WORK_IMAGE" "$EXTRA_ROOT_MIB"
attach_image "$WORK_IMAGE" "$WORK_DIR/mnt"
printf '%s\n' "$WORK_IMAGE" > "$WORK_DIR/work-image.path"
printf '%s\n' "$IMAGE_ROOT_MOUNT" > "$WORK_DIR/root-mount.path"
printf '%s\n' "$IMAGE_BOOT_MOUNT" > "$WORK_DIR/boot-mount.path"
printf '%s\n' "$IMAGE_LOOP" > "$WORK_DIR/loop.path"
