#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
IMAGE_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)
PROJECT_ROOT=$(cd -- "$IMAGE_DIR/../../.." && pwd)

SCRIPT_FILES=()
while IFS= read -r line; do SCRIPT_FILES+=("$line"); done < <(
  find "$IMAGE_DIR" -type f \( -name '*.sh' -o -path '*/bin/*' -o -name 'edgebox-first-boot' \) -print | sort
)
for script in "${SCRIPT_FILES[@]}"; do
  bash -n "$script"
done

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -x -e SC1091,SC2034 "${SCRIPT_FILES[@]}"
fi

test -x "$IMAGE_DIR/bin/build-image"
test -x "$IMAGE_DIR/rootfs/common/usr/local/sbin/edgebox-first-boot"
while IFS= read -r script; do test -x "$script"; done < <(find "$IMAGE_DIR/rootfs/common/usr/local/lib/edgebox/steps" -type f -name '*.sh')

grep -q '^BASE_IMAGE_URL=https://downloads.raspberrypi.com/' "$IMAGE_DIR/config/base-image.lock"
grep -Eq '^BASE_IMAGE_SHA256=[0-9a-f]{64}$' "$IMAGE_DIR/config/base-image.lock"
grep -q 'ConditionPathExists=!/var/lib/edgebox/first-boot.complete' \
  "$IMAGE_DIR/rootfs/common/etc/systemd/system/edgebox-first-boot.service"

docker compose \
  --env-file "$IMAGE_DIR/tests/fixtures/compose.env" \
  -f "$IMAGE_DIR/rootfs/apps/usr/local/share/edgebox/compose.yaml" \
  config --quiet

output=$(
  "$IMAGE_DIR/bin/build-image" \
    --config "$IMAGE_DIR/tests/fixtures/site.env" \
    --output-dir "$PROJECT_ROOT/dist/test-raspi" \
    --dry-run 2>&1
)
grep -q 'phase 70-validate-image' <<< "$output"
grep -q 'build complete' <<< "$output"

unsafe_config=$(mktemp "${TMPDIR:-/tmp}/edgebox-unsafe.XXXXXX")
trap 'rm -f "$unsafe_config"' EXIT
cp "$IMAGE_DIR/tests/fixtures/site.env" "$unsafe_config"
printf 'BASE_IMAGE_URL=https://example.invalid/evil.img.xz\n' >> "$unsafe_config"
if "$IMAGE_DIR/bin/build-image" --config "$unsafe_config" --dry-run >/dev/null 2>&1; then
  printf 'unsafe site key was accepted\n' >&2
  exit 1
fi

printf 'static image-builder tests passed\n'
