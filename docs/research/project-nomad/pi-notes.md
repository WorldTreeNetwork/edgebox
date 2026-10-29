# Notes for the Pi

Written 2026-10-28. Reads the 2026-10-19 NOMAD survey against the Edgebox Pi as it is recorded in this repo: `infrastructure/raspi/services/compose.yaml`, the catalog seed in `drizzle/0002_foamy_triton.sql` ("observed in deployment notes on 2026-09-21"), and `ARCHITECTURE.md`. The live Pi was not re-inspected for this note.

NOMAD's own install page says Raspberry Pi and other ARM boards are unsupported, and points those users at Internet in a Box. The pieces below are the ones that still make sense on a Pi 5. Their GPU chat story does not.

## What Edgebox already loads

The Compose file in this repo runs four application containers, bound to `192.168.0.90`:

| Already running in Compose | NOMAD also ships it? |
| --- | --- |
| Forgejo 16 | No. NOMAD has no git host. |
| Vaultwarden (`:latest`) | Yes, pinned `vaultwarden/server:1.36.0`, forced onto a self-signed HTTPS cert. |
| Vikunja (`:latest`) | No. Their closest cousin is FlatNotes, which is notes, not tasks. |
| Stirling PDF ultra-lite (`:latest`), login on | Yes, `s-pdf:2.13.1`, login turned off. |

The catalog seed also records services that were on the Pi that day and are not in this Compose file: File Browser, Navidrome, Jellyfin, Radarr, Sonarr, Lidarr, SABnzbd, FlareSolverr, Transmission, Prowlarr, Gluetun, Caddy, dnsmasq, Docker, Tailscale. Jellyfin and File Browser are the overlap with NOMAD's Supply Depot. Navidrome is an Edgebox capability NOMAD does not have. Forgejo is the other one.

The image plan adds SSH, Caddy, dnsmasq, and Docker on Raspberry Pi OS Lite. Desktop apps stay on the clients. Edgebox launches those services as labeled links. It does not start, stop, or upgrade them. That boundary is the whole comparison.

## Affordances their stack actually buys

**A library, not just an app list.** Kiwix is one reader for many corpora: Wikipedia, Wikibooks, Stack Exchange, Gutenberg, crawled government health sites, repair guides. The user picks a tier, sees a size, and after the download the same UI works with the WAN unplugged. Edgebox can launch Jellyfin or Forgejo. It cannot answer "what is oral rehydration?" from something stored on the SSD.

**Size is part of the choice.** Each ZIM and each map file has a catalog size and a snapshot date. The setup screen has a storage bar. That is how a 1 TB disk stays a decision instead of a surprise. Our catalog rows have summaries and launch URLs, and no byte count.

**One offline map, cut to the disk you have.** MapLibre draws PMTiles. Pre-cut US states live in their maps repo (Hawaii 28 MB, California 1.1 GB, vintage 2025-12). Anywhere else is a `pmtiles extract` from the current ProtoMaps build of OpenStreetMap, clipped with a Natural Earth polygon. Serving tiles is cheap. Cutting a zoom-15 country on a Pi is the expensive step, and it wants the SSD, not the boot card.

**A course player with its own students.** Kolibri 0.19.4 holds channels, classes, and progress. Khan Academy shows up only after an operator imports it from Kolibri Studio. The app is MIT and was built for small offline machines. The courses stay under each channel's license.

**A private chat over documents they already downloaded.** Ollama plus Qdrant embeds the ZIMs and uploads, then answers from those passages. The program is MIT. The weights are not. This affordance is why they refuse a Pi: the model needs RAM or VRAM about the size of the file, and they want a discrete GPU. A Pi 5 can run a 1B–3B quant slowly from system RAM. It does not get the product they advertise.

**Small single-purpose tools beside the library.** CyberChef, IT-Tools, Excalidraw, FlatNotes, Calibre-Web, Homebox, Meshtastic Web, MeshCore Web. Each is a container with a port. Most are stateless or one data directory. They make the box feel complete. They also make an unbounded app store.

**The management UI is root.** The admin container mounts the Docker socket, seeds apps from a table, pulls images, binds ports, and can update itself through a sidecar. That is the affordance of "add an app from the browser." It is also why a missing login on port 8080 is a remote root shell. Their disk collector mounts the host filesystem read-only so the UI can draw a storage bar. Dozzle shows logs, with container actions and the shell turned off.

**Updates are gated.** Minor and patch updates of the core and of installed apps can apply inside a time window, after a cool-off, and only if nothing else is downloading. Major versions stay manual. Content snapshots can refresh the same way. Image tags in their seeder are pins (`ollama:0.33.3`, `kiwix-serve:3.8.1`). Our Compose file uses `:latest` for Vaultwarden, Vikunja, and Stirling.

**Public reading is the default, accounts are per app.** Anyone on the LAN can open the library. Kolibri, Vaultwarden, File Browser, and Homebox grow their own accounts later. NOMAD cannot say "guests may see Wikipedia, members may open the vault." Edgebox already can: the catalog has `public` and `operator` visibility, and guests may open public entries.

**Content licenses stay with the publisher.** Apache 2.0 stops at their application. A ZIM of TED talks, a Llama weight file, and a Modern Rogue Creator Pack are not Apache. The Creator Packs are a separate draft license, gated by a key baked into the official image. That gate is an affordance for the video owners. It is a reason to leave those packs out of anything we ship.

## What is worth adding on the Pi 5

Ordered by how well it fits a headless Pi with an SSD, a capability catalog, and no Docker control plane. Adding one means a Compose service plus a catalog capability. It does not mean importing their admin app, MySQL, or Redis.

### 1. Kiwix, as "Look something up"

`ghcr.io/kiwix/kiwix-serve` is GPL-3.0. It is the highest-leverage package they run that a Pi 5 can actually host. One container, one data directory of ZIM files, guest-visible.

Start with a single small snapshot, not their comprehensive tiers. From their catalog, reasonable first files:

- English Wikipedia quick reference, `wikipedia_en_top_mini`, about 331 MB, CC BY-SA.
- Or the compact full Wikipedia, `wikipedia_en_all_mini`, about 12 GB, if the SSD has room. Skip `all-maxi` (about 124 GB) until the media disk is sized for it.
- A medicine ZIM if health reference is the point: the zimgit medicine bundle is 67 MB, the NHS medicines crawl is 16 MB, MedlinePlus is 1.8 GB. Prefer those over their openFDA indexer, which expands to 8–10 GB and is a medical-advice surface they had to write themselves.

Record the snapshot name, the size, and the content license on the capability page. Their catalog forgot the license field. Ours should not.

Internet in a Box is the project they name for Pis. If the goal is "a library image," that project has already done the content selection for ARM. Kiwix itself is the piece to run. Their installer is the piece to leave.

### 2. Calibre-Web, as "Read books"

GPL-3.0. We have File Browser and Jellyfin, and no bookshelf. They seed an empty Calibre `metadata.db` so first launch has a library path (`/books`). Books the household already owns stay in that folder. Fetch-metadata needs the network. Reading does not.

This pairs with the SSD layout in `PI-IMAGE-BUILD.md` (`/Media/` for large stores). It is a labeled launch with Calibre's own login, same shape as Vaultwarden.

### 3. A notes app, as "Take notes"

FlatNotes (`dullage/flatnotes`, MIT) is the one they picked: markdown files in one directory, no account in their config. Vikunja does not cover this. A notes capability is a real hole next to tasks, files, and passwords.

FlatNotes with auth off is a LAN-public notebook. For this box, turn auth on, or pick a notes server that can sit behind the same Caddy gate as the other member services. The files should live on the SSD next to the other `data/` directories.

### 4. Offline maps, as static tiles, not as a planet cutter

MapLibre and `pmtiles` serving are light. A pre-cut regional file from their maps repo, or one extract made on a bigger machine and copied to the Pi, is enough for "See a map." Running go-pmtiles against `build.protomaps.com` on the Pi is optional later.

The tiles are an OpenStreetMap ODbL produced work via ProtoMaps. Put that attribution on the map page. Their maps repo's MIT notice covers the scripts and style, not the tiles. Fonts in the style pack are SIL OFL. Sprites derive from tangrams/icons (MIT).

Natural Earth 1:50m country outlines are public domain and small (about 3 MB). Useful only if we grow an extract tool. A single copied `.pmtiles` does not need them.

### 5. Kolibri, later, as "Study a course"

MIT, and aimed at the hardware we have. It is the right way to get Khan Academy onto the Pi. Budget on the order of their FAQ's 50 GB once someone imports channels, and expect a second user system inside Kolibri. Edgebox should launch it and say that progress lives in Kolibri. It should not pretend Identikey is a Kolibri login.

Do this after Kiwix. A reference library is useful the day the ZIM lands. A course library is useful after someone curates channels.

## What to leave

**Their control plane.** AdonisJS, MySQL 8, Redis, BullMQ, the Docker socket, the updater sidecar, the disk-collector sidecar. The affordance is one-click install. The architecture we already accepted is that Edgebox observes health and launches approved URLs. Operators change Compose on the host. Copying their socket mount would throw that out.

**Ollama, Qdrant, and the RAG pipeline, for now.** The open-source programs fit in a container. A useful model does not fit the Pi they told people not to use. A later experiment can be a 1B-class model with the capability text saying it is small and slow. It should not be on the first library image. Embeddings of a full Wikipedia are a second disk and a long CPU job.

**Their Bergamot translation proxy.** Clever, and they pinned it to amd64 because `intgemm` has no aarch64 wheel in that build. Revisit only if an ARM build of Firefox translations exists and Kiwix is already in use.

**The openFDA drug database and the herb pages.** The public-domain source is real. The product is a custom SQLite app with a liability banner. A MedlinePlus or NHS ZIM gives the same job to Kiwix.

**CyberChef, IT-Tools, Excalidraw, Homebox, Meshtastic, MeshCore, Dozzle, the benchmark.** Fine software. IT-Tools and CyberChef are static and tiny, and still a new capability each ("Encode data", "Draw a diagram") that nobody has asked for. Meshtastic only matters if this Pi is also a radio desk. Homebox is household inventory. Dozzle is an operator log tail. The benchmark exists to feed their leaderboard.

**Creator Packs and the entitlement Worker.** Not open source. A fork is not allowed to redistribute them. Their draft license says so.

**Jellyfin, Vaultwarden, Stirling, File Browser.** Already ours. Two habits of theirs are still worth taking without new packages:

- Pin image tags or digests. `:latest` on Vaultwarden and Stirling is how a Tuesday pull changes the box.
- Put the vault on trusted HTTPS before real credentials, which is already the Edgebox plan. Their self-signed cert makes the Bitwarden web vault run. It also trains people to click through certificate warnings. Caddy with a private CA or Tailscale is the stronger version of the same affordance.

## A small set that would change the Pi

If only three containers were added to the current Compose file:

1. Kiwix, with one named Wikipedia ZIM on the SSD.
2. Calibre-Web, with an empty library on the SSD.
3. FlatNotes, or another MIT/Apache notes server, with auth, behind Caddy.

That adds "look something up," "read a book," and "take a note," which the current capability list does not have. Maps and Kolibri can follow once the disk budget is obvious. Chat can follow only if a small model is labeled as small.
