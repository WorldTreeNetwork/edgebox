#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${1:-} == --dry-run ]] && DRY_RUN=true
source "$IMAGE_DIR/lib/common.sh"
source "$IMAGE_DIR/lib/manifest.sh"

if is_true "${DRY_RUN:-false}"; then log "would compress the image and create checksum plus manifest"; exit 0; fi
mkdir -p "$OUTPUT_DIR"
raw_image=$(<"$WORK_DIR/work-image.path")
output_image=$OUTPUT_DIR/edgebox-${BASE_IMAGE_RELEASE}-${BASE_IMAGE_ARCH}.img.xz
xz --threads=0 --compress --stdout "$raw_image" > "$output_image"
sha256sum "$output_image" > "$output_image.sha256"
write_manifest "$output_image.manifest" "$output_image"
printf '%s\n' "$output_image" > "$WORK_DIR/output-image.path"
