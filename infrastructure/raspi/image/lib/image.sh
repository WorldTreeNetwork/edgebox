#!/usr/bin/env bash

# Partition access is userspace on purpose. The Mjolnir guest kernel
# (Cloud Hypervisor ch_defconfig) has loop, ext4, and vfat, and no
# CONFIG_MSDOS_PARTITION. Raspberry Pi OS images are MBR, so
# `losetup --partscan` never creates p1/p2 there. sfdisk reads the
# table from the file; each partition is its own offset loop.

IMAGE_LOOP=
IMAGE_BOOT_LOOP=
IMAGE_ROOT_MOUNT=
IMAGE_BOOT_MOUNT=

partition_sectors() {
  local image=${1:?image required} number=${2:?partition number required}
  sfdisk -d "$image" | awk -v want="$number" '
    /start=/ {
      n++
      if (n == want) {
        start = size = ""
        if (match($0, /start=[ ]*[0-9]+/)) {
          start = substr($0, RSTART, RLENGTH)
          sub(/start=[ ]*/, "", start)
        }
        if (match($0, /size=[ ]*[0-9]+/)) {
          size = substr($0, RSTART, RLENGTH)
          sub(/size=[ ]*/, "", size)
        }
        print start, size
        exit
      }
    }
  '
}

open_partition_loop() {
  local image=${1:?image required} number=${2:?partition number required}
  local start size
  read -r start size < <(partition_sectors "$image" "$number")
  [[ -n "${start:-}" && -n "${size:-}" && "$size" -gt 0 ]] || die "partition $number not found in $image"
  losetup --find --show --offset $((start * 512)) --sizelimit $((size * 512)) "$image"
}

record_attach() {
  [[ -n "${WORK_DIR:-}" ]] || return 0
  printf '%s\n' "$IMAGE_LOOP" > "$WORK_DIR/loop.path"
  printf '%s\n' "$IMAGE_BOOT_LOOP" > "$WORK_DIR/boot-loop.path"
  printf '%s\n' "$IMAGE_ROOT_MOUNT" > "$WORK_DIR/root-mount.path"
  printf '%s\n' "$IMAGE_BOOT_MOUNT" > "$WORK_DIR/boot-mount.path"
}

load_attach() {
  [[ -n "${WORK_DIR:-}" ]] || return 0
  if [[ -f "$WORK_DIR/loop.path" ]]; then IMAGE_LOOP=$(<"$WORK_DIR/loop.path"); fi
  if [[ -f "$WORK_DIR/boot-loop.path" ]]; then IMAGE_BOOT_LOOP=$(<"$WORK_DIR/boot-loop.path"); fi
  if [[ -f "$WORK_DIR/root-mount.path" ]]; then IMAGE_ROOT_MOUNT=$(<"$WORK_DIR/root-mount.path"); fi
  if [[ -f "$WORK_DIR/boot-mount.path" ]]; then IMAGE_BOOT_MOUNT=$(<"$WORK_DIR/boot-mount.path"); fi
}

attach_image() {
  local image=${1:?image required}
  local mount_base=${2:?mount base required}
  require_root
  require_command sfdisk
  mkdir -p "$mount_base/root" "$mount_base/boot"
  IMAGE_LOOP=$(open_partition_loop "$image" 2)
  IMAGE_BOOT_LOOP=$(open_partition_loop "$image" 1)
  IMAGE_ROOT_MOUNT=$mount_base/root
  IMAGE_BOOT_MOUNT=$mount_base/boot
  mount "$IMAGE_LOOP" "$IMAGE_ROOT_MOUNT"
  mount "$IMAGE_BOOT_LOOP" "$IMAGE_BOOT_MOUNT"
  export IMAGE_LOOP IMAGE_BOOT_LOOP IMAGE_ROOT_MOUNT IMAGE_BOOT_MOUNT
  record_attach
}

detach_image() {
  set +e
  [[ -n "${IMAGE_BOOT_MOUNT:-}" ]] && mountpoint -q "$IMAGE_BOOT_MOUNT" && umount "$IMAGE_BOOT_MOUNT"
  [[ -n "${IMAGE_ROOT_MOUNT:-}" ]] && mountpoint -q "$IMAGE_ROOT_MOUNT" && umount "$IMAGE_ROOT_MOUNT"
  [[ -n "${IMAGE_BOOT_LOOP:-}" ]] && losetup "$IMAGE_BOOT_LOOP" >/dev/null 2>&1 && losetup -d "$IMAGE_BOOT_LOOP"
  [[ -n "${IMAGE_LOOP:-}" ]] && losetup "$IMAGE_LOOP" >/dev/null 2>&1 && losetup -d "$IMAGE_LOOP"
  set -e
  IMAGE_LOOP=
  IMAGE_BOOT_LOOP=
  IMAGE_ROOT_MOUNT=
  IMAGE_BOOT_MOUNT=
}

grow_image() {
  local image=${1:?image required}
  local extra_mib=${2:?extra MiB required}
  local start size loop rc
  require_root
  require_command sfdisk
  truncate -s "+${extra_mib}M" "$image"
  # Extend partition 2 to the end of the file. The table edit is userspace;
  # the kernel is not asked to re-read an MBR it may not understand.
  printf ', +\n' | sfdisk --no-reread --no-tell-kernel -N 2 "$image"
  read -r start size < <(partition_sectors "$image" 2)
  loop=$(losetup --find --show --offset $((start * 512)) --sizelimit $((size * 512)) "$image")
  rc=0
  e2fsck -pf "$loop" || rc=$?
  if [[ "$rc" -gt 1 ]]; then
    losetup -d "$loop" || true
    die "e2fsck failed on the grown root partition (exit $rc)"
  fi
  rc=0
  resize2fs "$loop" || rc=$?
  losetup -d "$loop" || true
  [[ "$rc" -eq 0 ]] || die "resize2fs failed on the grown root partition (exit $rc)"
}
