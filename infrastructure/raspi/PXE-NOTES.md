# Existing Raspberry Pi PXE server

Snapshot taken from `raspi` (`192.168.0.90`) on 2026-09-21. Preserve this
design when turning Edgebox into a reproducible Raspberry Pi or memory-card
image.

## Boot flow

1. `dnsmasq` supplies DHCP on `eth0` and TFTP-serves `/srv/tftp/ipxe.efi`.
2. The custom iPXE EFI binary chain-loads the boot script.
3. iPXE retrieves the Arch kernel, initramfs, and root filesystem over HTTP.
4. Caddy serves `/srv/http/archiso` at `/archiso/` and the build repository at
   `/repo/`.

This is an offline-capable Arch Linux network boot. There is no NFS export in
the current configuration.

## Services

- `dnsmasq`: enabled and active
- `caddy`: enabled and active
- `rpcbind`: active, but not needed by the current HTTP-root PXE flow
- TFTP root: `/srv/tftp`
- HTTP roots: `/srv/http/archiso` and `/srv/http/repo`

## dnsmasq configuration

Source: `/etc/dnsmasq.d/pxe-proxy.conf`

```ini
interface=eth0
bind-interfaces
log-dhcp

dhcp-range=192.168.0.100,192.168.0.200,255.255.255.0,1h
dhcp-option=3,192.168.0.1
dhcp-option=6,192.168.0.1

enable-tftp
tftp-root=/srv/tftp
dhcp-boot=ipxe.efi
```

Despite the filename, this is an authoritative DHCP range rather than
dnsmasq's `proxy` DHCP mode. A reusable image must make the interface, subnet,
gateway, DNS server, and DHCP ownership configurable to avoid conflicting with
the LAN router.

## Caddy configuration

Source: the PXE block in `/etc/caddy/Caddyfile`.

```caddyfile
http://:80 {
	handle_path /tftp/* {
		root * /srv/tftp
		file_server
	}
	handle_path /archiso/* {
		root * /srv/http/archiso
		file_server browse
	}
	handle_path /repo/* {
		root * /srv/http/repo
		file_server browse
	}
}
```

The live Caddyfile also serves Jellyfin at `movies.local` using Caddy's
internal TLS issuer; that is separate from PXE.

## Files to preserve or regenerate

```text
/srv/tftp/
  boot.ipxe
  ipxe-arch.efi
  ipxe.efi

/srv/http/
  archiso/              # Arch ISO payload and overlay.img
  repo/                 # installer/build repository
    pxe/
      autorun.sh
      boot.ipxe
      bootstrap.sh
      Caddyfile
      deploy.sh
      dnsmasq-pxe.conf
      setup-pxe-server.sh
      overlay/
```

For the image build, keep the small configuration and scripts in source
control, but fetch or build large Arch ISO artifacts during provisioning.

The broader OS, storage, security, application, first-boot, and validation
requirements are tracked in [`PI-IMAGE-BUILD.md`](./PI-IMAGE-BUILD.md).
