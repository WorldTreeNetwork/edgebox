# Edgebox Raspberry Pi image builder

This pipeline produces a customised Raspberry Pi OS Lite 64-bit image. It
downloads a checksum-pinned official base, operates only on a disposable copy,
injects an idempotent first-boot provisioner, removes unique identity, and
emits a compressed image with checksum and provenance manifest.

## Build host

A real build requires Linux and root privileges for loop devices and mounts.
Install `curl`, `xz-utils`, `coreutils`, `util-linux`, `cloud-guest-utils`,
`parted`, `e2fsprogs`, and `rsync`. macOS can run static tests and `--dry-run`
but cannot perform the image lifecycle directly.

## Configure

```sh
cp infrastructure/raspi/image/config/site.example.env \
  infrastructure/raspi/image/config/site.env
```

Set a real SSH public key. Keep secrets out of this file and out of Git. A
router-side DHCP reservation is the preferred stable-address strategy.

## Build

```sh
sudo infrastructure/raspi/image/bin/build-image \
  --config infrastructure/raspi/image/config/site.env
```

Artifacts are written to `dist/raspi/`. Use Raspberry Pi Imager's **Use
Custom** option to flash the resulting `.img.xz` file.

Profiles may be selected in `site.env` or appended on the command line. `core`
and `apps` are usable. The `pxe` profile is deliberately gated until a pinned,
checksummed custom iPXE binary and boot payload are added.

## Validate without building

```sh
infrastructure/raspi/image/tests/static.sh
infrastructure/raspi/image/bin/build-image \
  --config infrastructure/raspi/image/tests/fixtures/site.env \
  --dry-run
```

## First boot

The image runs `edgebox-first-boot.service` after networking becomes ready.
Each step has its own completion marker, so a failed boot can resume safely.
The overall completion marker is written only after validation passes. Logs are
available through `journalctl -u edgebox-first-boot` and at
`/var/log/edgebox/first-boot.log`.
