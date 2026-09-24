# Raspberry Pi image build notes

This is the implementation checklist for turning the current `raspi` host into
a reproducible Edgebox memory-card image. Build scripts should be unattended,
idempotent, safe to rerun, and divided into image-time and first-boot phases.

## Recommended build path

Use an official Raspberry Pi OS image as the input for the first version of
Edgebox:

1. Download a **pinned Raspberry Pi OS Lite (64-bit)** image from Raspberry
   Pi's official downloads host.
2. Verify the compressed image against the SHA-256 published on the official
   operating-systems page and run `xz --test`.
3. Expand and customise the image on a Linux build host or Linux CI runner.
4. Add Edgebox files, packages, and a one-shot first-boot systemd unit.
5. Remove build-host identity and secrets, unmount cleanly, compress the final
   image, generate its checksum and manifest, and test it on a Pi 5.
6. Flash the result with Raspberry Pi Imager using **Use Custom**. Imager is the
   writing/verification tool in this flow, not the configuration source of
   truth.

The product is now called **Raspberry Pi OS**, not Raspbian. Raspberry Pi's
official headless recommendation is the Lite image. As of this review on
2026-09-21, the current 64-bit Lite release is Debian 13 (Trixie), dated
2026-09-15, with Linux 6.18:

```text
BASE_IMAGE_URL=https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2026-09-15/2026-09-15-raspios-trixie-arm64-lite.img.xz
BASE_IMAGE_SHA256=cdf4f3bfac35ae947b46e4e767f935453810549779ac3290e05a6754aee627e5
BASE_IMAGE_RELEASE=2026-09-15
BASE_IMAGE_DEBIAN_CODENAME=trixie
BASE_IMAGE_ARCH=arm64
```

Keep those values in a reviewed lock file when scripts are implemented. Do not
use an unversioned `latest` URL in release builds. Updating the base is a
deliberate change: inspect release notes, update URL and checksum together,
build, then run the complete image test suite. Retain the upstream SBOM with
the build artifacts when one exists for the exact release.

Example acquisition logic for the eventual script:

```sh
curl --fail --location --retry 3 --output "$cache_path/$image_name" "$BASE_IMAGE_URL"
printf '%s  %s\n' "$BASE_IMAGE_SHA256" "$cache_path/$image_name" | sha256sum --check -
xz --test "$cache_path/$image_name"
```

The alternative official tool, `rpi-image-gen`, constructs customised images
from Debian packages, produces an SBOM, and is worth evaluating later. It is
not the same as modifying an official Raspberry Pi OS Lite image; Raspberry
Pi explicitly notes that it does not provide a Raspberry Pi OS Lite/Desktop
profile. Starting from the released Lite image therefore gives us the closest
match to the ordinary supported Pi install while we establish the build.

## Build inputs

Require an explicit configuration file rather than baking site-specific values
into the image:

- hostname and primary user
- SSH public keys
- timezone and locale
- wired interface name
- static address or DHCP choice
- LAN subnet, gateway, and DNS resolver
- whether this host owns DHCP, provides proxy DHCP, or leaves DHCP disabled
- PXE DHCP range and boot architecture
- local domain and HTTPS strategy
- enabled application profiles
- external data-disk device, filesystem, and mount point

Refuse to enable authoritative DHCP unless the operator explicitly selects it.
The current Pi serves `192.168.0.100-200`; blindly cloning that setting could
create a second DHCP server on another network.

## Image-time base system

- Start with the checksum-pinned official Raspberry Pi OS Lite 64-bit image
  for Raspberry Pi 5 described above.
- Update packages and install current firmware and kernel packages.
- Install: `openssh-server`, `curl`, `ca-certificates`, `jq`, `git`, `rsync`,
  `dnsmasq`, and `caddy`.
- Install Docker Engine from its signed upstream repository plus the Compose
  plugin; do not use the convenience install script in the final build.
- Add the management user to the `docker` group, but keep scripts compatible
  with `sudo docker` until the next login.
- Enable time synchronization and set the configured timezone/locale.
- Enable SSH key authentication. Disable password SSH and root SSH only after
  confirming at least one supplied public key was installed.
- Keep the image headless; desktop applications such as VLC, OpenOffice, and
  ebook readers belong on clients, while browser-accessible services run here.

## Kernel and boot configuration

- Enable memory cgroups so Docker can account for and enforce Compose memory
  limits. First test the stock current image: do not blindly append legacy
  `cgroup_enable=memory cgroup_memory=1` flags copied from old Pi tutorials.
  Apply a release-specific remediation only if the clean-image test fails.
  Verify after boot with `docker info` and a container with a small memory
  limit, not merely by inspecting the kernel command line.
- Keep the Raspberry Pi 5 ARM64 kernel and firmware aligned with the chosen OS
  release.
- Enable required container networking modules and `/dev/net/tun` when the VPN
  profile is selected.
- Do not copy the live card's machine identity. Regenerate machine ID, SSH host
  keys, DHCP client identity, and similar unique host material on first boot.
- Grow the root filesystem on first boot when the image is written to a larger
  card.

## Storage layout

Use stable paths so application configuration is easy to back up and restore:

```text
/home/<user>/services/edgebox/       # Compose definition
/home/<user>/services/edgebox/data/  # application databases and config
/srv/tftp/                           # TFTP boot artifacts
/srv/http/archiso/                   # network-boot payloads
/srv/http/repo/                      # installer/build repository
/Media/                              # optional large external media disk
```

- Prefer an SSD or other external disk for Nextcloud files, media, and future
  document stores. Do not fill the boot card with user data.
- Resolve disks by filesystem UUID, create mount points and permissions, and
  verify mounts before starting containers that depend on them.
- Never format a disk merely because the expected label or UUID is absent;
  require an explicit destructive provisioning flag.
- Configure periodic database-aware backups of `services/edgebox/data`, plus
  tested restore instructions. A Compose file alone is not a backup.
- Configure Docker log rotation and a disk-space alert. Prune unused images on
  a schedule only after pulls/upgrades succeed; never prune volumes
  automatically.

## Networking, names, and HTTPS

- Prefer a DHCP reservation in the router for the Edgebox address. This is the
  current Raspberry Pi recommendation for servers. If a device-side static
  address is required, render a NetworkManager connection and apply it through
  `nmcli`; do not write legacy `/etc/dhcpcd.conf` or boot-partition
  `wpa_supplicant.conf` instructions. Raspberry Pi OS has used NetworkManager
  since Bookworm, and boot-partition `wpa_supplicant.conf` provisioning is no
  longer supported.
- Bind administrative application ports to the selected LAN address, not
  `0.0.0.0`, unless an exposure profile explicitly requests otherwise.
- Give applications stable local names and route them through Caddy.
- Establish a trusted HTTPS approach before enabling Vaultwarden for real use:
  local DNS plus a trusted private CA, a controlled public domain, or an
  authenticated Tailscale deployment.
- Install the chosen private CA on client devices when using Caddy internal
  certificates. Merely accepting a browser warning is not the desired setup.
- Keep direct application ports available only during bootstrap, then make
  Caddy the normal entry point.
- Do not expose any service directly to the public internet by default.
- Make firewall policy explicit: SSH, HTTP/HTTPS, selected LAN app ports, TFTP,
  DHCP, and Forgejo SSH. Restrict management access to the LAN or VPN. Docker
  published ports can bypass `ufw`/firewalld rules; enforce container ingress
  through supported `iptables`/`ip6tables` rules in the `DOCKER-USER` chain in
  addition to binding ports to the LAN address.
- If Tailscale is selected, authenticate it during first boot with a short-lived
  or tagged auth key supplied at runtime; never bake that key into the image.

## PXE profile

The exact observed layout and current configuration are in
[`PXE-NOTES.md`](./PXE-NOTES.md). Build scripts should:

- install and enable `dnsmasq` and Caddy only when the PXE profile is enabled
- render dnsmasq settings from validated network inputs
- support authoritative DHCP, proxy DHCP, and TFTP-only modes
- stage `ipxe.efi`, `ipxe-arch.efi`, and `boot.ipxe` under `/srv/tftp`
- build or verify the custom iPXE binary and record its source commit
- stage Arch kernel/initramfs/rootfs artifacts under `/srv/http/archiso`
- publish installer scripts under `/srv/http/repo`
- keep large ISO-derived artifacts out of Git and fetch/build them with pinned
  versions and verified checksums
- validate rendered dnsmasq configuration before restart
- validate Caddy configuration before reload
- test TFTP retrieval and every HTTP URL referenced by `boot.ipxe`
- avoid installing NFS/rpcbind unless a future boot flow actually requires it

## Application profile

Install the Compose stack from [`services/compose.yaml`](./services/compose.yaml)
and create its bind-mounted data directories with explicit ownership.

Initial lightweight profile:

- Forgejo
- Vaultwarden
- Vikunja
- Stirling PDF Ultra-Lite

Existing/optional profiles discovered on the current host:

- File Browser
- Jellyfin, Navidrome, and the Arr/download stack
- VPN routing through Gluetun

Do not install overlapping products by default: OwnCloud plus Nextcloud, Emby
plus Jellyfin, or a second File Browser. Keep Nextcloud, Docmost, Rocket.Chat,
Infisical, and AI/evaluation platforms opt-in because of their RAM, storage,
or database requirements.

- Pin at least major application versions. Record image digests in release
  artifacts for fully repeatable builds.
- Pull images during provisioning when online; optionally preload an OCI image
  bundle for offline installation.
- Run `docker compose config --quiet` before starting anything.
- Wait for health/readiness endpoints rather than assuming container `running`
  means the application is ready.
- Never bake generated admin passwords, API tokens, SMTP credentials, VPN
  credentials, or Tailscale auth keys into the image.

## First-boot provisioning

First boot should be a one-shot systemd unit with a durable log and completion
marker. It should:

1. Regenerate unique machine and SSH identities.
2. Grow the filesystem and validate free space.
3. Apply hostname, locale, timezone, and network configuration.
4. Install operator SSH keys and verify access prerequisites.
5. Mount and validate optional data disks.
6. Render dnsmasq, Caddy, firewall, and Compose configuration from inputs.
7. Generate runtime secrets with a cryptographically secure generator and
   store them in root-readable files outside Git.
8. Start infrastructure services, then application services in dependency
   order.
9. Run readiness checks and write a concise installation report containing
   URLs and manual onboarding steps, but no secret values.
10. Disable and mask the first-boot unit after success. On failure, retain logs
    and permit a safe rerun without destroying data.

Manual onboarding remains intentional for the first release:

- create the first Forgejo administrator
- create the first Vaultwarden and Vikunja users
- change Stirling PDF's initial password
- disable open registration after initial accounts exist
- establish and test trusted HTTPS before using Vaultwarden

Raspberry Pi Imager normally preconfigures hostname, locale, user credentials,
networking, and SSH for a headless install. Edgebox must deliver equivalent
outcomes from its version-controlled first-boot input. If the builder elects
to use Raspberry Pi OS's manual boot-partition convention, it must create both
the empty `ssh` marker and `userconf.txt` containing a SHA-512-crypt password;
an `ssh` marker alone no longer creates a usable default `pi` account. Prefer
our systemd provisioner and injected SSH public keys so no reusable password is
embedded in distributed images.

Do not duplicate stock first-boot work. Detect whether the official image will
already expand its root filesystem and regenerate identities, then test those
behaviours. Edgebox's unit should own only the additional configuration that
the stock image or Imager does not provide.

## Updates and operations

- Separate OS updates from application-image updates.
- Back up persistent data before application upgrades.
- Pull images, recreate containers, run readiness checks, and retain enough
  information to roll back to the prior image digests.
- Avoid unattended major-version application upgrades.
- Provide commands for status, logs, backup, restore, update, rollback, and
  unused-image cleanup.
- Capture service versions and image digests in an installation manifest.
- Add basic monitoring for disk use, memory pressure, container restarts,
  unhealthy containers, certificate expiry, and failed backups.

## Image validation gates

Automated image tests should fail the build or first boot unless all applicable
checks pass:

- package manager and `dpkg` are clean
- no reboot is pending after image-time updates
- SSH accepts the supplied key and rejects prohibited authentication modes
- Docker and Compose run ARM64 images natively
- memory cgroup accounting and limits work
- root filesystem has the configured minimum free space
- expected external disks are mounted before dependent services start
- `docker compose config --quiet` succeeds
- all selected containers remain running without restart loops
- each selected HTTP endpoint returns an expected status
- Caddy and dnsmasq configurations validate
- PXE TFTP and HTTP artifacts are reachable when the PXE profile is selected
- firewall rules match the selected exposure profile
- no default credentials, build-time secrets, or first-boot auth keys remain
  in the final filesystem or logs
- a backup and restore smoke test succeeds against disposable sample data

## Comparison with current official guidance

Reviewed 2026-09-21 against the official sources listed below.

| Area                   | Edgebox decision after comparison                                                                                                                                           |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Base OS                | Use official Raspberry Pi OS Lite 64-bit, currently Debian 13 Trixie; do not call it Raspbian in scripts or UI.                                                             |
| Flashing               | Raspberry Pi Imager remains the standard writer and can flash our result via **Use Custom**. Keep build customisation in source-controlled scripts.                         |
| Headless setup         | Match Imager's hostname, locale, account, networking, and SSH outcomes. Prefer injected SSH keys and a first-boot unit over a shared password.                              |
| Wi-Fi/network          | Use NetworkManager/`nmcli`; the old boot-volume `wpa_supplicant.conf` technique is obsolete. Prefer a router DHCP reservation over a device static IP.                      |
| Docker                 | The official Debian repository supports Debian 13 and arm64. Use its signed apt repository; Docker says the convenience script is for testing/development.                  |
| Firewall               | Account for Docker's documented bypass of `ufw`/firewalld rules and manage container filtering in `DOCKER-USER`.                                                            |
| Custom image generator | Keep `rpi-image-gen` as a future alternative for fully declarative-from-packages images and SBOM generation, not as a claim that we are starting from Raspberry Pi OS Lite. |
| PXE                    | Pi 5 supports network boot, but our DHCP/TFTP/Caddy implementation remains an Edgebox profile and must never be enabled without explicit LAN configuration.                 |

### Official references

- [Raspberry Pi OS downloads](https://www.raspberrypi.com/software/operating-systems/)
- [Raspberry Pi installation and headless setup](https://www.raspberrypi.com/documentation/computers/getting-started.html)
- [Raspberry Pi network configuration](https://www.raspberrypi.com/documentation/computers/configuration.html)
- [Raspberry Pi Imager source and custom repository support](https://github.com/raspberrypi/rpi-imager)
- [Raspberry Pi rpi-image-gen](https://github.com/raspberrypi/rpi-image-gen)
- [Raspberry Pi introduction to rpi-image-gen](https://www.raspberrypi.com/news/introducing-rpi-image-gen-build-highly-customised-raspberry-pi-software-images/)
- [Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)
