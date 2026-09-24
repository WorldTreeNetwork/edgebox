#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${1:-} == --dry-run ]] && DRY_RUN=true
source "$IMAGE_DIR/lib/common.sh"

if [[ $(uname -s) != Linux ]]; then
  if is_true "${DRY_RUN:-false}"; then warn "real builds require Linux"; else die "real builds require Linux"; fi
fi
for command in curl xz sha256sum awk sed find; do require_command "$command"; done
if ! is_true "${DRY_RUN:-false}"; then
  require_root
  for command in losetup mount umount mountpoint sfdisk e2fsck resize2fs rsync; do require_command "$command"; done
fi
log "configuration and host prerequisites passed"
