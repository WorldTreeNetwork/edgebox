# Edgebox service stack

The live copy is deployed at `/home/duke/services/edgebox` on `raspi`. All
published ports bind only to the Pi's LAN address (`192.168.0.90`), not to
every host interface.

| Service      | URL                        | Initial action                                                                                          |
| ------------ | -------------------------- | ------------------------------------------------------------------------------------------------------- |
| Forgejo      | <http://192.168.0.90:3000> | Complete the install form and create the first admin. Git SSH uses port `2222`.                         |
| Vaultwarden  | <http://192.168.0.90:8222> | Add HTTPS before storing real credentials; then create the first account and disable open registration. |
| Vikunja      | <http://192.168.0.90:3456> | Register the first account, then disable open registration.                                             |
| Stirling PDF | <http://192.168.0.90:8082> | Sign in as `admin` / `stirling` and immediately change the password.                                    |

Persistent application data is under `data/` beside the Compose file. Back up
that directory before upgrades.

## Operations

```sh
cd /home/duke/services/edgebox
sudo docker compose ps
sudo docker compose logs --tail=100
sudo docker compose pull
sudo docker compose up -d
```

## Known host constraint

The current Pi kernel/cgroup configuration does not expose container memory
accounting or limits to Docker. Compose retains conservative `mem_limit`
values as desired policy, but Docker currently discards them. Enable memory
cgroups in the future image build before relying on those limits.

Vaultwarden's web vault requires a secure browser context for cryptographic
operations. The HTTP listener is useful for initial reachability testing but
is not the finished security posture. Prefer a trusted HTTPS name through
Caddy once local DNS or Tailscale is configured.
