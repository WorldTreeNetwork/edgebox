#!/usr/bin/env bash

write_manifest() {
  local output=${1:?output required}
  local image=${2:?image required}
  local digest
  digest=$(sha256sum "$image" | awk '{print $1}')
  {
    printf 'format_version=1\n'
    printf 'built_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'git_commit=%s\n' "$(git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null || printf unknown)"
    printf 'base_url=%s\n' "$BASE_IMAGE_URL"
    printf 'base_sha256=%s\n' "$BASE_IMAGE_SHA256"
    printf 'base_release=%s\n' "$BASE_IMAGE_RELEASE"
    printf 'architecture=%s\n' "$BASE_IMAGE_ARCH"
    printf 'profiles=%s\n' "$EDGEBOX_PROFILES"
    printf 'image=%s\n' "$(basename "$image")"
    printf 'image_sha256=%s\n' "$digest"
  } > "$output"
}
