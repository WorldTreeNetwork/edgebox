# Edgebox Raspberry Pi image builder

This pipeline produces a customised Raspberry Pi OS Lite 64-bit image. It
downloads a checksum-pinned official base, operates only on a disposable copy,
injects an idempotent first-boot provisioner, removes unique identity, and
emits a compressed image with checksum and provenance manifest.

## Build host

A real build requires Linux and root, for loop devices and mounts. Install
`curl`, `ca-certificates`, `xz-utils`, `coreutils`, `fdisk` (for `sfdisk`),
`e2fsprogs`, and `rsync`. Partition tables are edited with `sfdisk` and mounted by byte
offset, so the host kernel does not need an MBR parser. That is what makes
the build run in a Mjolnir guest. macOS can run the static checks and
`--dry-run`, not the image lifecycle.

`mj spawn --target raspi-image` uses the defaults in the repo `mjolnir.toml`
(Ubuntu 24.04, 4096 MiB, DHCP, `core,apps`). Forgejo runs
`.forgejo/workflows/raspi-image.yml` on the same kind of guest. A committed
`config/site.env` is never required: without one, the build uses those
defaults and a test-only SSH key.

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
