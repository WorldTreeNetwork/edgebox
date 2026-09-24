#!/usr/bin/env bash

IMAGE_LOOP=
IMAGE_ROOT_MOUNT=
IMAGE_BOOT_MOUNT=

attach_image() {
  local image=${1:?image required}
  local mount_base=${2:?mount base required}
  require_root
  mkdir -p "$mount_base/root" "$mount_base/boot"
  IMAGE_LOOP=$(losetup --find --show --partscan "$image")
  IMAGE_ROOT_MOUNT=$mount_base/root
  IMAGE_BOOT_MOUNT=$mount_base/boot
  mount "${IMAGE_LOOP}p2" "$IMAGE_ROOT_MOUNT"
  mount "${IMAGE_LOOP}p1" "$IMAGE_BOOT_MOUNT"
  export IMAGE_LOOP IMAGE_ROOT_MOUNT IMAGE_BOOT_MOUNT
}

detach_image() {
  set +e
  [[ -n "${IMAGE_BOOT_MOUNT:-}" ]] && mountpoint -q "$IMAGE_BOOT_MOUNT" && umount "$IMAGE_BOOT_MOUNT"
  [[ -n "${IMAGE_ROOT_MOUNT:-}" ]] && mountpoint -q "$IMAGE_ROOT_MOUNT" && umount "$IMAGE_ROOT_MOUNT"
  [[ -n "${IMAGE_LOOP:-}" ]] && losetup "$IMAGE_LOOP" >/dev/null 2>&1 && losetup -d "$IMAGE_LOOP"
  set -e
  IMAGE_LOOP=
  IMAGE_ROOT_MOUNT=
  IMAGE_BOOT_MOUNT=
}

grow_image() {
  local image=${1:?image required}
  local extra_mib=${2:?extra MiB required}
  require_root
  truncate -s "+${extra_mib}M" "$image"
  local loop
  loop=$(losetup --find --show --partscan "$image")
  growpart "$loop" 2
  partprobe "$loop"
  e2fsck -pf "${loop}p2" || [[ $? -eq 1 ]]
  resize2fs "${loop}p2"
  losetup -d "$loop"
}
