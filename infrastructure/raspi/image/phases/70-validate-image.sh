#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${1:-} == --dry-run ]] && DRY_RUN=true
source "$IMAGE_DIR/lib/common.sh"

if is_true "${DRY_RUN:-false}"; then log "would verify packaged checksum, compression, manifest, and secret scan"; exit 0; fi
output_image=$(<"$WORK_DIR/output-image.path")
(cd "$(dirname "$output_image")" && sha256sum --check "$(basename "$output_image").sha256")
xz --test "$output_image"
for key in base_url base_sha256 git_commit profiles image_sha256; do
  grep -q "^$key=" "$output_image.manifest" || die "manifest missing $key"
done
if grep -Eiq '(PRIVATE KEY-----|PASSWORD=.+|TOKEN=.+|SECRET=.+)' "$CONFIG_FILE"; then
  die "site configuration appears to contain a secret; use runtime secret provisioning"
fi
log "packaged image validation passed"
