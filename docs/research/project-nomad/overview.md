# Overview

[Project NOMAD](https://www.projectnomad.us/) is a free offline knowledge and education server from Crosstalk Solutions, LLC. Chris Sherwood started it in 2025. The name began as a backronym, "Node for Offline Maps, Archives, and Data." The project now just uses NOMAD. That history is in [`admin/docs/about.md`](https://github.com/Crosstalk-Solutions/project-nomad/blob/main/admin/docs/about.md).

The software is Apache 2.0. Source and install script:

```bash
curl -fsSL https://raw.githubusercontent.com/Crosstalk-Solutions/project-nomad/main/install/install_nomad.sh -o install_nomad.sh
sudo bash install_nomad.sh
```

After install, the Command Center listens on port 8080. Content, models, and notes live under `/opt/project-nomad/storage`.

## What a running box contains

NOMAD is a management UI and API that starts other containers through the host Docker socket. The management stack itself is five containers, from [`install/management_compose.yaml`](https://github.com/Crosstalk-Solutions/project-nomad/blob/main/install/management_compose.yaml):

| Container | Image | Role |
| --- | --- | --- |
| `nomad_admin` | `ghcr.io/crosstalk-solutions/project-nomad:latest` | Command Center. AdonisJS API plus React UI. |
| `nomad_mysql` | `mysql:8.0` | Catalog state, chat history, drug index metadata, installed-resource rows. |
| `nomad_redis` | `redis:7-alpine` | BullMQ job queues. |
| `nomad_updater` | `ghcr.io/crosstalk-solutions/project-nomad-sidecar-updater:latest` | Recreates the admin container from inside the UI. |
| `nomad_disk_collector` | `ghcr.io/crosstalk-solutions/project-nomad-disk-collector:latest` | Read-only host disk stats for the storage bar. |
| `nomad_dozzle` | `amir20/dozzle:v10.0` | Optional log viewer on port 9999. Actions and shell are turned off. |

The admin image is built from `node:22-slim` and also installs `go-pmtiles` **1.30.2** so it can cut regional map extracts. See [Software stack](software-stack.md).

Apps the user turns on (Kiwix, Ollama, Kolibri, and the Supply Depot) are separate containers. They are seeded from `admin/database/seeders/service_seeder.ts` and start only after the user selects them. A fresh install downloads none of the libraries.

The README's own size split: the management app is about 5 GB of disk and under 1 GB of RAM. Adding the AI assistant lands near 25 GB because Ollama and one general-purpose model are large. Content after that is whatever the user picks. The in-app FAQ quotes full English Wikipedia around 95 GB and a Khan Academy import around 50 GB. The website's Wikipedia selector quotes the illustrated "all maxi" snapshot at about 125 GB (`collections/wikipedia.json` says 123,980 MB for the 2026-02 file).

## What the website says is inside

The homepage groups the product into four modules:

| Module | Engine named on the site | What the repo actually ships |
| --- | --- | --- |
| Information Library | Kiwix | `kiwix-serve` 3.8.1 serving ZIM files from `download.kiwix.org`, plus an FDA label database that is not a ZIM. |
| AI Assistant | Ollama | Ollama 0.33.3, Qdrant for retrieval, optional OpenAI-compatible backends (LM Studio, llama.cpp). |
| Offline Maps | OpenStreetMap | ProtoMaps vector tiles built from OpenStreetMap, rendered with MapLibre. Pre-cut US states, plus a live extract of any country from the current ProtoMaps planet build. |
| Education | Kolibri | Kolibri 0.19.4. Khan Academy and other courses are imported by the operator from Kolibri Studio. NOMAD does not pin a Khan Academy file. |

Also built in, and easy to miss on the homepage: CyberChef, FlatNotes, a hardware benchmark, a Supply Depot of extra containers, a drug reference, a translated-library proxy, and optional Creator Packs (project videos, Crosstalk Solutions videos, Modern Rogue videos).

The Supply Depot catalog on `main` adds Stirling PDF, File Browser, Calibre-Web, IT Tools, Excalidraw, Homebox, Vaultwarden, Jellyfin, Meshtastic Web, and MeshCore Web. The README also says you can register an arbitrary Docker image.

## Who it is aimed at

The site names four audiences: emergency preparedness, off-grid living (cabin, RV, sailboat), people who want a private local model, and families who want Khan Academy and Wikipedia for Schools without a connection. Hardware guidance pushes the opposite direction from a Raspberry Pi: Ubuntu 26.04 LTS (22.04+ or Debian 12 also accepted), a Ryzen 7 or Intel i7 class CPU, 32 GB RAM, a Radeon 780M or a dedicated NVIDIA GPU, and a 1 TB SSD.

Explicitly unsupported on the install page: Raspberry Pi and other ARM boards, virtual machines (Proxmox, Hyper-V, VMware), and macOS. The page points Pi users at [Internet in a Box](https://internet-in-a-box.org/). Windows is a community path through WSL2, documented at `/install/wsl2`, with their own numbers showing an RTX 3090 Ti about 18% slower on token rate under WSL2 than on bare-metal Ubuntu.

There is no built-in login. The install page links a community Caddy basic-auth guide for `/settings` and the admin APIs (`/install/caddy`). The README says the box is meant for a local network and advises against publishing it on the public internet. A public roadmap item tracks optional accounts: [roadmap.projectnomad.us](https://roadmap.projectnomad.us/posts/1/user-authentication-please-build-in-user-auth-with-admin-user-roles).

## Sites around the project

| Host | Role |
| --- | --- |
| [www.projectnomad.us](https://www.projectnomad.us/) | Marketing and install guides. A Next.js site. Its source is not in the `project-nomad` repo. |
| [github.com/Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad) | Application, catalog JSON, installer, in-app docs (`admin/docs/`). |
| [api.projectnomad.us](https://api.projectnomad.us) | Release-note subscription and the recommended-model list (`/api/v1/ollama/models`). Also used as an internet-up check. |
| [benchmark.projectnomad.us](https://benchmark.projectnomad.us) | Optional leaderboard. Submit goes to `/api/v1/submit`. |
| [roadmap.projectnomad.us](https://roadmap.projectnomad.us) | Public feature voting. |
| `nomad-packs-worker.chris-556.workers.dev` | Cloudflare Worker that gates Creator Pack downloads. Official images bake `CREATOR_PACKS_APP_KEY` at build time. A from-source build leaves the key empty and hides the packs UI. |
| Discord `discord.com/invite/crosstalksolutions` | Support, `#project-nomad`. |
| Ko-fi `ko-fi.com/crosstalk` | Funding. The support page also points at Rogue Support, a paid home-network consult. |

In-app documentation (getting started, FAQ, drug reference, Supply Depot, community add-ons) ships inside the admin image from `admin/docs/` and is rendered with Markdoc.

## Comparison the site draws

The homepage compares NOMAD with PrepperDisk, Doom Box, R.E.A.D.I., and Z3R4H on price, model size, whether the hardware is locked to a Pi, multi-user serving, Wikipedia coverage, maps, Khan Academy, and whether the software is open source. Those rows are the project's own marketing claims. This survey did not re-test the other products.

## Network behavior while a connection exists

The README states there is no product telemetry. The connectivity probe tries `https://1.1.1.1/cdn-cgi/trace`, then the GitHub API and `api.projectnomad.us`. Settings can replace that URL, and `INTERNET_STATUS_TEST_URL` overrides the UI. Qdrant is started with `QDRANT__TELEMETRY_DISABLED=true`.

These calls happen only when the operator asks for them, or when automatic updates are turned on:

- GitHub and GHCR, for NOMAD image updates and for the pre-cut map files.
- `download.kiwix.org` and `opds.library.kiwix.org`, for ZIM files and "is there a newer snapshot?"
- `build-metadata.protomaps.dev` and `build.protomaps.com`, for the planet basemap.
- `api.fda.gov`, for drug labels.
- The Ollama model registry, for weights.
- Firefox Remote Settings, for translation models.
- Kolibri Studio, if the operator imports a channel.
- `benchmark.projectnomad.us`, if the operator submits a score.
- The Creator Pack Worker, if an official image installs a pack.

The Excalidraw container's own docs, quoted in NOMAD's Supply Depot page, say that build phones Simple Analytics when it is online. That is Excalidraw's behavior, called out in NOMAD's own notes.

Automatic updates are opt-in. Minor and patch updates of the Command Center and of installed apps can apply inside a time window after a cool-off. Major versions stay manual. Content snapshots can refresh the same way.

## Security facts that matter if you copy the design

- The admin container mounts `/var/run/docker.sock`. Anyone who can reach the unbound Command Center can ask it to start containers.
- File Browser seeds `admin` / `nomad`. Calibre-Web's upstream default, documented by NOMAD, is `admin` / `admin123`. Vaultwarden generates its own account and uses a self-signed certificate.
- The disk collector mounts the host filesystem read-only (`/:/host:ro,rslave`).
- Downloads refuse private and loopback URLs (`assertNotPrivateUrl` in the map downloader).
- The Creator Pack key is baked into the public GHCR image layer. The Dockerfile comment says that is an accepted ceiling, and that rotation is a new image plus a Worker secret.

## Hardware the project itself shows off

The [NOMAD Deck](https://www.projectnomad.us/deck) page (September 2026) is Chris Sherwood's reference build: Minisforum UM890 Pro, 1 TB drive, ARZOPA 16.1 inch screen, ProtoArc folding keyboard, EcoFlow RIVER 2 (240 Wh) inside a Pelican 1510. He measured about 21 W idle (screen off, about 10 hours), about 28 W browsing (about 7 hours), and about 91 W with the local model generating continuously (about 2 hours 15 minutes). The page says that particular library fits in 1 TB with about 500 GB free, and that a Meshtastic link at a Modern Rogue shoot asked the box questions with no internet. Community builds are listed at [/builds](https://www.projectnomad.us/builds), including Michael Klements' 3D-printed 10-inch rack around a Beelink SER9 MAX.
