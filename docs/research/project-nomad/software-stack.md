# Software stack

Versions are the pins in `main` on 2026-10-19, from `admin/database/seeders/service_seeder.ts`, `install/management_compose.yaml`, `Dockerfile`, and `admin/package.json`. Upstream SPDX ids were read from GitHub that day. "Image" is what NOMAD starts. "License" is the upstream project's license, which is independent of NOMAD's Apache 2.0.

## NOMAD's own code

| Piece | Where | License |
| --- | --- | --- |
| Command Center (API, UI, catalog, downloader, RAG, drug index, benchmark) | `admin/`, image `ghcr.io/crosstalk-solutions/project-nomad` | Apache 2.0. Copyright Crosstalk Solutions, LLC. |
| Installer, start/stop/update/uninstall | `install/*.sh` | Apache 2.0, same repo. |
| Sidecar updater | `install/sidecar-updater/`, image `ghcr.io/crosstalk-solutions/project-nomad-sidecar-updater` | Apache 2.0. |
| Disk collector | `install/sidecar-disk-collector/`, image `ghcr.io/crosstalk-solutions/project-nomad-disk-collector` | Apache 2.0. |
| Translated Library proxy | `install/nomad-translate/` (`proxy.py`, `blocks.py`, `fetch_models.py`), image `ghcr.io/crosstalk-solutions/project-nomad-translate:0.1.1` | Apache 2.0 for their proxy. The Bergamot wheel it runs is MPL 2.0. |
| Benchmark workload image | `ghcr.io/crosstalk-solutions/nomad-sysbench@sha256:1f08e527f5d4…e13f0` | Their multi-arch image: Debian 12 plus sysbench 1.0.20+ds-5, built so ARM hosts are not stuck on the amd64-only `severalnines/sysbench` image. sysbench itself is GPL-2.0. |
| Map style package | [project-nomad-maps](https://github.com/Crosstalk-Solutions/project-nomad-maps) `base-assets.tar.gz` | Fonts are SIL OFL (from [protomaps/basemaps-assets](https://github.com/protomaps/basemaps-assets)). Sprites derive from [tangrams/icons](https://github.com/tangrams/icons), MIT. The maps repo's closing paragraph also says "MIT" for the repo as a whole. The tile files in that repo are a separate license. See [Data sources](data-sources.md). |
| US state boundary cutter | `convert_shapefile.py` and `extract_states.sh` in `project-nomad-maps` | Script text is under that repo's MIT claim. The polygons come from the US Census TIGER/Line shapefile. |

The UI is TypeScript: AdonisJS 6 on the server, Inertia with React 19 on the client. The volunteer page says the same thing. Docs inside the app are Markdoc.

## Platform the installer puts on the machine

| Software | Pin | License | Why it is here |
| --- | --- | --- | --- |
| Docker Engine and Compose | Whatever the install script sets up on Ubuntu/Debian | Engine (Moby) is Apache 2.0. Compose is Apache 2.0. | Every app is a container. The admin talks to the host socket with the `dockerode` 5.0.0 client. |
| MySQL | `mysql:8.0` | GPL-2.0 for MySQL Community Server. | Nomad's own database: services, downloads, chat, drug labels, benchmark rows. |
| Redis | `redis:7-alpine` (floating tag) | Redis 7.4 and later (2024) are RSALv2 or SSPL, dual-licensed, not the old BSD. A `redis:7` tag can resolve to that generation. Confirm the digest before you rely on a BSD reading. | BullMQ 5.77.6 queues for downloads, model pulls, embeds, and benchmarks. |
| Node.js | `node:22-slim` in the admin Dockerfile | MIT for Node itself; the image bundles other Debian packages. | Runtime. |
| Dozzle | `amir20/dozzle:v10.0` | MIT | Log UI. `DOZZLE_ENABLE_ACTIONS=false` and `DOZZLE_ENABLE_SHELL=false`. |

Debian packages installed in the admin image: bash, curl, openssl, graphicsmagick (for `pdf2pic`), libvips (for `sharp`), build-essential, pciutils.

## Core apps the user can turn on

Seeded as first-class services. Ports are the host ports in the seeder.

| App | Image on `main` | Host port | Upstream | License |
| --- | --- | --- | --- | --- |
| Information Library | `ghcr.io/kiwix/kiwix-serve:3.8.1` | 8090 | [kiwix/kiwix-tools](https://github.com/kiwix/kiwix-tools) | GPL-3.0 |
| AI Assistant | `ollama/ollama:0.33.3` | 11434 | [ollama/ollama](https://github.com/ollama/ollama) | MIT. Model weights have their own licenses. |
| Vector index for that assistant | `qdrant/qdrant:v1.16` | 6333, 6334 | [qdrant/qdrant](https://github.com/qdrant/qdrant) | Apache 2.0. Telemetry env is forced off. |
| Education Platform (Gen 2) | `learningequality/kolibri:0.19.4` | 8310 UI, 8311 zip content | [learningequality/kolibri](https://github.com/learningequality/kolibri) | MIT. Channel content is not MIT. |
| Data Tools | `ghcr.io/gchq/cyberchef:10.24.0` | 8100 | [gchq/CyberChef](https://github.com/gchq/CyberChef) | Apache 2.0 |
| Notes | `dullage/flatnotes:v5.5.4` | 8200 | [dullage/flatnotes](https://github.com/dullage/flatnotes) | MIT. Auth type `none`. |
| Translated Library | `ghcr.io/crosstalk-solutions/project-nomad-translate:0.1.1` | 8460 | NOMAD proxy in front of Kiwix, using [browsermt/bergamot-translator](https://github.com/browsermt/bergamot-translator) | Proxy: Apache 2.0. Bergamot: MPL 2.0. The PyPI `bergamot` wheel dates from 2022-06-21. Firefox translation models: MPL 2.0. |

Kolibri Gen 1 (`treehouses/kolibri:0.12.8`) is still recognized so old installs keep running on port 8300. New installs get Gen 2. A migration deprecates the old image. Data is not migrated; the operator re-imports channels. The volume path changed from `/root/.kolibri` to `/kolibri`.

Ollama can be pointed at another host. The README requires `OLLAMA_HOST=0.0.0.0` on that host. An OpenAI-compatible server (LM Studio, llama.cpp) works for chat. Model download stays an Ollama feature, so those other servers do not get NOMAD's model picker.

## Supply Depot

Same seeder. These start only when chosen. Custom images are allowed on top of this list. The guard in `custom_app_guard.ts` blocks some unsafe binds. NOMAD does not vendor these codebases. It pulls the image.

| App | Image | Host port | Upstream | License |
| --- | --- | --- | --- | --- |
| Stirling PDF | `ghcr.io/stirling-tools/s-pdf:2.13.1` | 8400 | [Stirling-Tools/Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF) | MIT for the open tree. The upstream LICENSE carves out `app/proprietary/`, `app/saas/`, `engine/`, and several frontend directories under their own licenses. NOMAD sets `SECURITY_ENABLELOGIN=false`. |
| File Browser | `filebrowser/filebrowser:v2` | 8410 | [filebrowser/filebrowser](https://github.com/filebrowser/filebrowser) | Apache 2.0. Seeded login `admin` / `nomad` (bcrypt hash in the seeder). |
| Calibre-Web | `linuxserver/calibre-web:0.6.26-ls386` | 8420 | [janeczku/calibre-web](https://github.com/janeczku/calibre-web) | GPL-3.0. LinuxServer builds the image. NOMAD ships an empty Calibre `metadata.db`. |
| IT Tools | `ghcr.io/corentinth/it-tools:2024.10.22-7ca5933` | 8430 | [CorentinTh/it-tools](https://github.com/CorentinTh/it-tools) | GPL-3.0 |
| Excalidraw | `excalidraw/excalidraw:sha-4bfc5bb` | 8440 | [excalidraw/excalidraw](https://github.com/excalidraw/excalidraw) | MIT. Drawings stay in the browser. The image still has the upstream analytics call when online. |
| Meshtastic Web | `ghcr.io/meshtastic/web:2.7.1` | 8450 | [meshtastic/web](https://github.com/meshtastic/web) | GPL-3.0. Browser client for Meshtastic radios. The old Meshtastic daemon container was removed (`sunset_meshtastic_daemon` migration). |
| Homebox | `ghcr.io/sysadminsmedia/homebox:0.26.2` | 8470 | [sysadminsmedia/homebox](https://github.com/sysadminsmedia/homebox) | AGPL-3.0. Continuation of hay-kot/homebox, which was archived in June 2024. |
| Vaultwarden | `vaultwarden/server:1.36.0` | 8480, HTTPS | [dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden) | AGPL-3.0. Bitwarden-compatible server. NOMAD generates a self-signed cert at install. The official Bitwarden clients are a separate license (Bitwarden's own). |
| Jellyfin | `jellyfin/jellyfin:10.11.11` | 8490 | [jellyfin/jellyfin](https://github.com/jellyfin/jellyfin) | GPL-2.0 |
| MeshCore Web | `ghcr.io/axistem-dev/meshcore-web:v1.45.0` | 8500, HTTPS | [aXistem-dev/meshcore-web](https://github.com/aXistem-dev/meshcore-web), a packaged build of Liam Cottle's MeshCore web client | No SPDX license detected on that GitHub repo on 2026-10-19. Treat the image as third-party with an unset license until the repo states one. Served with a self-signed cert so Web Bluetooth and Web Serial are allowed. |

## Libraries compiled into the Command Center

Direct dependencies from `admin/package.json`. Transitive packages are not listed. Grouped by what they do in NOMAD.

| Concern | Packages (version on `main`) | Notes |
| --- | --- | --- |
| HTTP server and ORM | `@adonisjs/core` 6.19.3, `@adonisjs/lucid` 21.8.2, `@adonisjs/auth` 9.6.0, `@adonisjs/session` 7.7.1, `@adonisjs/shield` 8.2.0, `@adonisjs/cors` 2.2.1, `@adonisjs/static` 1.1.1, `edge.js` 6.4.0, `mysql2` 3.22.5 | AdonisJS is MIT. Auth is bundled even though the product ships with no login. |
| UI | `@adonisjs/inertia` 3.1.1, `@inertiajs/react` 2.3.13, `react` 19.2.7, `react-dom` 19.2.7, `@headlessui/react` 2.2.9, `@tabler/icons-react` 3.36.1, `tailwindcss` 4.2.2, `@tanstack/react-query` 5.90.20, `@tanstack/react-virtual` 3.13.18 | React is MIT. |
| Docs and chat markdown | `@markdoc/markdoc` 0.5.4, `react-markdown` 10.1.0, `remark-gfm` 4.0.1, CodeMirror 6 (`codemirror` 6.0.2 and `@codemirror/*`) | In-app docs and the notes/chat editors. |
| AI clients | `ollama` 0.6.3, `openai` 6.38.0, `@qdrant/js-client-rest` 1.16.2, `@chonkiejs/core` 0.0.7 | Chat, embeddings, chunking. |
| Retrieval extras | `better-sqlite3` 12.6.2, `stopword` 3.1.5, `fuse.js` 7.1.0 | Drug-label search and fuzzy matching. The drug corpus itself is loaded into SQLite. |
| ZIM and maps | `@openzim/libzim` 4.0.0 (GPL-2.0), `pmtiles` 4.4.0, `@protomaps/basemaps` 5.7.0, `maplibre-gl` 4.7.1 (BSD-3-Clause), `react-map-gl` 8.1.0 | libzim reads ZIM files from Node. MapLibre draws the vector tiles. go-pmtiles 1.30.2 is the CLI beside these, BSD-3-Clause, installed from GitHub releases in the Dockerfile with pinned SHA-256. |
| Documents the user uploads | `pdf-parse` 2.4.5, `pdf2pic` 3.2.0, `mammoth` 1.12.0, `tesseract.js` 7.0.0, `sharp` 0.34.5, `jszip` 3.10.1, `yauzl` 2.10.3 | Knowledge-base ingest: PDF, docx, OCR, images, zip. |
| Uploads and jobs | `@uppy/core` 5.2.0 and dashboard/react/xhr plugins, `bullmq` 5.77.6, `ioredis` 5.10.1 | File upload UI and the job queue. |
| Ops | `dockerode` 5.0.0, `systeminformation` 5.31.7, `axios` 1.18.1, `pino-pretty` 13.1.3, `@scalar/api-reference` 1.62.4 | Docker control, benchmark host stats, HTTP, OpenAPI UI. |
| Realtime | `@adonisjs/transmit` 2.0.2, `react-adonis-transmit` 1.0.1 | Server-sent events for download and benchmark progress. |

Country polygons used to draw an extract region ship in-repo as `admin/resources/geodata/ne_50m_admin_0_countries.geojson`. That file is Natural Earth 1:50 million Admin-0 countries. Natural Earth releases its data into the public domain. The file is about 3 MB.

## Open-source projects NOMAD tells you to use, and does not vendor

| Project | Where it shows up | License relationship |
| --- | --- | --- |
| Ubuntu Desktop 26.04 LTS, or Debian 12 | Install guide | Ubuntu's mix of licenses. NOMAD does not redistribute the ISO. |
| Rufus, Balena Etcher | Install guide, for the USB stick | Their own licenses. |
| OpenSSH | Optional `apt install openssh-server` in the install guide | BSD-style OpenSSH license, via Ubuntu. |
| Caddy | Community guide `/install/caddy` for a basic-auth gate | Apache 2.0. Not started by the installer. |
| Kolibri Studio | Where course channels are imported from | Learning Equality's service. Content licenses are per channel. |
| Bitwarden client apps | How you open a Vaultwarden vault from a phone | Bitwarden's client license, separate from Vaultwarden's AGPL. |
| Internet in a Box | Suggested alternative for a Raspberry Pi | Their project, not a NOMAD dependency. |

## Programs that are not open source, sitting next to the open ones

These run inside the same product. They are listed here so the Apache 2.0 headline is not read as covering them. Provenance is in [Data sources](data-sources.md).

- Creator Pack videos (Project NOMAD, Crosstalk Solutions, The Modern Rogue). Draft license `nomad-creator-pack-1.0` in `collections/creator-pack-license.md`. Personal, non-commercial, no redistribution, no training use. The file says it is a draft pending legal review.
- Ollama model weights. Llama, DeepSeek, Nomic, and whatever else the operator pulls keep the upstream weight license.
- Kiwix ZIMs of commercial or creator video (TED, Canadian Prepper, Urban Prepper, Learning Self-Reliance) and of sites that are not openly licensed.
- Khan Academy lessons imported through Kolibri. NOMAD's FAQ treats them as content you download into Kolibri. Khan Academy's materials are under Khan Academy's terms (much of the text and exercises are CC BY-NC-SA; many videos are more restricted). NOMAD does not relicense them.
- The Bitwarden-compatible clients, if you install them.
- Excalidraw's hosted "plus" features, which the Supply Depot notes say do not work on an offline box.
