#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${1:-} == --dry-run ]] && DRY_RUN=true
source "$IMAGE_DIR/lib/common.sh"

if is_true "${DRY_RUN:-false}"; then
  log "would inject common and selected profile overlays plus first-boot configuration"
  exit 0
fi
require_root
root_mount=$(<"$WORK_DIR/root-mount.path")
boot_mount=$(<"$WORK_DIR/boot-mount.path")

rsync -a "$IMAGE_DIR/rootfs/common/" "$root_mount/"
IFS=',' read -ra profiles <<< "$EDGEBOX_PROFILES"
for profile in "${profiles[@]}"; do
  [[ -d "$IMAGE_DIR/rootfs/$profile" ]] || die "unknown or missing profile overlay: $profile"
  if [[ "$profile" == pxe && ! -f "$IMAGE_DIR/rootfs/pxe/srv/tftp/ipxe.efi" ]]; then
    die "PXE profile is not releasable until a pinned ipxe.efi artifact is staged"
  fi
  rsync -a "$IMAGE_DIR/rootfs/$profile/" "$root_mount/"
done

install -d -m 0700 "$root_mount/etc/edgebox"
install -m 0600 "$IMAGE_DIR/config/defaults.env" "$root_mount/etc/edgebox/defaults.env"
install -m 0600 "$CONFIG_FILE" "$root_mount/etc/edgebox/site.env"
printf '%s\n' "$EDGEBOX_PROFILES" > "$root_mount/etc/edgebox/profiles"
chmod 0600 "$root_mount/etc/edgebox/profiles"

# Retain a non-secret copy on bootfs for recovery/inspection. The validator
# rejects private-key and password-shaped fields from site configuration.
install -d -m 0755 "$boot_mount/edgebox"
sed -E '/(PRIVATE_KEY|PASSWORD|TOKEN|SECRET)=/Id' "$CONFIG_FILE" > "$boot_mount/edgebox/site.env"
chmod 0644 "$boot_mount/edgebox/site.env"
touch "$boot_mount/ssh"

ln -sf /etc/systemd/system/edgebox-first-boot.service \
  "$root_mount/etc/systemd/system/multi-user.target.wants/edgebox-first-boot.service"
