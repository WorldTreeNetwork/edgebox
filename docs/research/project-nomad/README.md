# Project NOMAD

Survey of [projectnomad.us](https://www.projectnomad.us/) and the public repository [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad), taken on **2026-10-19**.

Latest GitHub release that day: **v1.35.1**, published 2026-10-05. The notes below follow `main`, which already contains work past that tag (repo metadata `updated_at` 2026-10-20). Stars were about 40,600 and forks about 4,100. Both counts move.

## What this records

Project NOMAD is an offline-first knowledge appliance. You install it on a Debian-family PC, it downloads the libraries you pick, and those libraries keep working after the network is gone. The optional chat model runs on that same machine.

The Apache 2.0 grant covers the NOMAD application. It does not cover Wikipedia, maps, courses, videos, model weights, or the Creator Packs. Each of those stays under its publisher's terms. The catalog JSON in the repo does not store a license field per file, so the license column in these notes is the publisher's known terms, not a field NOMAD asserts.

## Pages

- [Overview](overview.md) — who publishes it, how a box is put together, what the website claims, and the security posture.
- [Software stack](software-stack.md) — every open-source program the appliance runs or compiles in, with the image tag or package version pinned in `main` and the upstream license.
- [Data sources](data-sources.md) — every pinned download: ZIM files, maps, FDA labels, remedy text, translation models, AI weights, Kolibri channels, and Creator Packs, and the host each one comes from.
- [Notes for the Pi](pi-notes.md) — what that stack affords, and which pieces are worth adding to the Raspberry Pi 5. A 1 TB SSD and tight RAM narrow that to Kiwix plus cold files. Updated 2026-10-28.

## How this was checked

Read from the public web and GitHub on 2026-10-19. No NOMAD instance was installed.

- Marketing site: home, install, WSL2 install, guides, FAQ, support, volunteer, deck, builds, Modern Rogue page.
- Repo: `README.md`, `FAQ.md`, `Dockerfile`, `install/management_compose.yaml`, `admin/database/seeders/service_seeder.ts`, `admin/package.json`, `admin/docs/*`, `collections/*.json`, `admin/constants/kiwix.ts`, `admin/constants/map_regions.ts`, `admin/app/services/map_service.ts`, `admin/app/services/drug_reference_service.ts`, `admin/app/services/creator_pack_service.ts`, `admin/app/services/benchmark_service.ts`, `install/nomad-translate/README.md`.
- Sibling repo [project-nomad-maps](https://github.com/Crosstalk-Solutions/project-nomad-maps) README, which states how the US state tiles were cut.
- SPDX license lookup on the upstream GitHub repositories named in the seeder. Where GitHub returned no SPDX id, the upstream `LICENSE` file was read (Stirling PDF, MapLibre).

Versions below are whatever `main` pinned that day. NOMAD's updater moves patch versions of installed containers, and the Kiwix catalog replaces ZIM filenames when Kiwix publishes a newer snapshot.
