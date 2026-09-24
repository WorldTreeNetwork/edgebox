#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${1:-} == --dry-run ]] && DRY_RUN=true
source "$IMAGE_DIR/lib/common.sh"

BASE_ARCHIVE=$CACHE_DIR/$BASE_IMAGE_FILENAME
export BASE_ARCHIVE
if is_true "${DRY_RUN:-false}"; then
  log "would fetch $BASE_IMAGE_URL to $BASE_ARCHIVE and verify $BASE_IMAGE_SHA256"
  exit 0
fi
mkdir -p "$CACHE_DIR"
if [[ ! -f "$BASE_ARCHIVE" ]]; then
  partial=$BASE_ARCHIVE.partial
  curl --fail --location --retry 3 --continue-at - --output "$partial" "$BASE_IMAGE_URL"
  mv "$partial" "$BASE_ARCHIVE"
fi
printf '%s  %s\n' "$BASE_IMAGE_SHA256" "$BASE_ARCHIVE" | sha256sum --check -
xz --test "$BASE_ARCHIVE"
printf '%s\n' "$BASE_ARCHIVE" > "$WORK_DIR/base-archive.path"
