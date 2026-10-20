# Data sources

Nothing in the knowledge library is authored by NOMAD except the small remedy-and-condition tables and the packaging. Everything else is downloaded from a publisher, then stored under `/opt/project-nomad/storage`.

The Apache 2.0 license on the application does not extend to these files. `collections/kiwix-categories.json` records an id, a title, a URL, a size, and a version. It does not record a license. The license notes below are the publisher's terms, checked against that publisher's own practice, and they are not a field the catalog enforces.

Sizes are the `size_mb` values in the catalog on 2026-10-19. Higher tiers include every resource of the tiers under them (`includesTier`), so a "standard" install is the essential list plus the standard list.

Catalog spec dates in the repo:

| File | Spec version |
| --- | --- |
| `collections/kiwix-categories.json` | 2026-03-15 |
| `collections/wikipedia.json` | 2026-08-02 |
| `collections/maps.json` | 2026-02-11 |
| `collections/conditions.json` | 2026-06-07 |
| `collections/natural_remedies.json` | 2026-06-10 |
| `collections/home_remedies.json` | 2026-06-10 |
| `collections/creator-packs.json` | spec 1, pack version 2026-07 |

## How a file arrives

```
publisher  →  packager  →  host NOMAD downloads from  →  local store  →  reader
```

| Kind | Packager | Download host | Reader on the box |
| --- | --- | --- | --- |
| Encyclopedia, books, crawled sites, videos | Kiwix / openZIM, as ZIM | `https://download.kiwix.org/zim/...` | `kiwix-serve` 3.8.1 |
| "Is there a newer ZIM?" | Kiwix OPDS catalog | `https://opds.library.kiwix.org/catalog/v2/entries` | Command Center. The human site `browse.library.kiwix.org` grew an interstitial in August 2026, so NOMAD stopped using it. See `admin/constants/kiwix.ts`. |
| FDA drug labels | openFDA bulk export | `https://api.fda.gov/download.json` (the manifest; the parts hang off that) | NOMAD's own Drug Reference, SQLite via `better-sqlite3` |
| US state map tiles | Crosstalk, cut from a ProtoMaps build | `https://github.com/Crosstalk-Solutions/project-nomad-maps` raw files | MapLibre in the Command Center |
| World and arbitrary-country tiles | ProtoMaps daily build of OpenStreetMap | `https://build-metadata.protomaps.dev/builds.json` then `https://build.protomaps.com/...` | `pmtiles extract` (go-pmtiles 1.30.2) writes a local `.pmtiles` |
| Map fonts and sprites | ProtoMaps assets, Tangram icons | `base-assets.tar.gz` in `project-nomad-maps` | MapLibre style |
| Country outlines for the extract tool | Natural Earth | Shipped in the NOMAD repo | `countries_service.ts` |
| Courses | Kolibri Studio channels | Studio, when the operator imports | Kolibri 0.19.4 |
| Chat models | Each model vendor, via the Ollama library | Ollama's registry, or a cache at `api.projectnomad.us/api/v1/ollama/models` for the recommendation list | Ollama 0.33.3 |
| Embeddings | Nomic | Ollama tag `nomic-embed-text:v1.5` | Qdrant v1.16 |
| Translation models | Mozilla Firefox Translations | Firefox Remote Settings (the endpoint Firefox uses) | Bergamot, behind NOMAD's proxy |
| Creator videos | The creators, packaged by Crosstalk | Cloudflare Worker `nomad-packs-worker.chris-556.workers.dev` | Their video player inside the Command Center |
| User documents | The operator | Upload in the UI | Chunked into Qdrant for RAG. Formats: PDF, docx, images (OCR via tesseract.js), zip. |

A user can also point Kiwix at a ZIM they already have. Custom library sources have their own table (`custom_library_sources`). Community packs documented in `admin/docs/community-add-ons.md` do this with `zimwriterfs`.

Two small ZIM filenames sit in the repo at `install/wikipedia_en_100_mini_2025-06.zim` and `install/wikipedia_en_100_mini_2026-01.zim`. This survey did not download those blobs. The catalog the UI offers is `collections/wikipedia.json`, which points at `download.kiwix.org`, not at those files.

## Wikipedia

Host: `https://download.kiwix.org/zim/wikipedia/`. Kiwix builds these from Wikimedia database dumps with openZIM. Article text is CC BY-SA 4.0. Images inside a "maxi" file keep whatever license each file had on Wikimedia Commons, which is a mix.

The operator picks one. They are alternatives, not a stack.

| Id | Name in the UI | Snapshot | Catalog size | File |
| --- | --- | --- | --- | --- |
| `top-mini` | Quick Reference | 2026-06 | 331 MB | `wikipedia_en_top_mini_2026-06.zim` |
| `top-nopic` | Popular Articles | 2026-06 | 2,239 MB | `wikipedia_en_top_nopic_2026-06.zim` |
| `all-mini` | Complete Wikipedia (Compact) | 2026-06 | 12,531 MB | `wikipedia_en_all_mini_2026-06.zim` |
| `all-nopic` | Complete Wikipedia (No Images) | 2026-06 | 52,690 MB | `wikipedia_en_all_nopic_2026-06.zim` |
| `all-maxi` | Complete Wikipedia (Full) | 2026-02 | 123,980 MB | `wikipedia_en_all_maxi_2026-02.zim` |

`all-maxi` is the "about 125 GB" figure on the website. The in-app FAQ's "~95 GB" is an older round number and does not match this pin.

A separate medicine slice, `wikipedia_en_medicine_maxi_2026-01.zim` (2,000 MB), is in the Medicine comprehensive tier. Same Wikimedia chain, limited to medical articles.

## Curated ZIM tiers

Path prefix on `download.kiwix.org` tells you who packaged the bytes:

| Prefix | What Kiwix did |
| --- | --- |
| `/zim/wikipedia`, `/zim/wikibooks`, `/zim/wikiversity` | Wikimedia dumps through openZIM. Text is CC BY-SA. |
| `/zim/gutenberg` | Project Gutenberg, split by Library of Congress class. Most of those books are public domain in the United States. |
| `/zim/stack_exchange` | Stack Exchange data dumps. Subscriber content on those sites is CC BY-SA. |
| `/zim/devdocs` | A snapshot of [DevDocs](https://devdocs.io), which aggregates upstream manuals. Python's docs are the PSF license. MDN (the HTML, CSS, and JavaScript books) is CC BY-SA. Each book follows its upstream manual. |
| `/zim/freecodecamp` | freeCodeCamp curriculum. The curriculum source is BSD-3-Clause. |
| `/zim/libretexts` | LibreTexts textbooks. LibreTexts' default grant is CC BY-NC-SA. |
| `/zim/ifixit` | iFixit repair guides. iFixit publishes the guides as CC BY-NC-SA. |
| `/zim/ted` | TED and TED-Ed videos packaged by Kiwix. The talks stay under TED's copyright. This is not an open-content dump. |
| `/zim/videos` | YouTube-style channels packaged by Kiwix (Canadian Prepper, Urban Prepper, Learning Self-Reliance). Copyright stays with the channel. |
| `/zim/zimit` | A website crawled with Zimit (a browser render dumped into a ZIM). The crawl is a copy of that site. The site's own terms still apply. |
| `/zim/other/zimgit-*` | "Zimgit" collections: books and manuals Kiwix contributors gathered into one ZIM. Licenses vary per book inside the file. |
| `/zim/other/librepathology_*` | LibrePathology, a MediaWiki. Typical Wikimedia-style CC BY-SA, confirm inside the ZIM. |

### Medicine

Essential (recommended):

| Title | Snapshot | MB | File | Upstream material |
| --- | --- | --- | --- | --- |
| Medical Library | 2024-08 | 67 | `zim/other/zimgit-medicine_en_2024-08.zim` | Zimgit bundle of field and emergency medicine books. Mixed book licenses. |
| NHS Medicines A to Z | 2025-12 | 16 | `zim/zimit/nhs.uk_en_medicines_2025-12.zim` | Crawl of nhs.uk medicines pages. NHS England content is published under the Open Government Licence. |
| Military Medicine | 2025-06 | 78 | `zim/zimit/fas-military-medicine_en_2025-06.zim` | Crawl of the Federation of American Scientists military-medicine mirror. Many of those manuals are US government works. |
| CDC Health Information | 2024-11 | 170 | `zim/zimit/wwwnc.cdc.gov_en_all_2024-11.zim` | Crawl of wwwnc.cdc.gov. CDC pages are US government works. |

Standard adds:

| Title | Snapshot | MB | File | Upstream material |
| --- | --- | --- | --- | --- |
| MedlinePlus | 2025-01 | 1,800 | `zim/zimit/medlineplus.gov_en_all_2025-01.zim` | Crawl of MedlinePlus (National Library of Medicine). US government work. |
| FDA Drug Reference | 2025-01 | 1,700 download, about 8–10 GB after index | `https://api.fda.gov/download.json` | Not a ZIM. openFDA drug-label dataset. US government work. Indexed locally. See below. |

Comprehensive adds:

| Title | Snapshot | MB | File | Upstream material |
| --- | --- | --- | --- | --- |
| Wikipedia Medicine | 2026-01 | 2,000 | `zim/wikipedia/wikipedia_en_medicine_maxi_2026-01.zim` | Wikimedia medical articles, CC BY-SA, with images. |
| LibreTexts Medicine | 2025-01 | 1,100 | `zim/libretexts/libretexts.org_en_med_2025-01.zim` | LibreTexts medical textbooks. |
| LibrePathology | 2026-09 | 95 | `zim/other/librepathology_en_all_maxi_2026-09.zim` | LibrePathology wiki. |

### Survival and preparedness

Essential:

| Title | Snapshot | MB | File | Upstream material |
| --- | --- | --- | --- | --- |
| Water Treatment Library | 2024-08 | 20 | `zim/other/zimgit-water_en_2024-08.zim` | Zimgit book bundle. |
| Food for Preppers | 2025-04 | 97 | `zim/other/zimgit-food-preparation_en_2025-04.zim` | Zimgit book bundle. The agriculture tier pins the same id at 98 MB. |
| A Library of Knots | 2024-08 | 27 | `zim/other/zimgit-knots_en_2024-08.zim` | Zimgit book bundle. |
| Canadian Prepper: Winter Prepping | 2026-08 | 1,342 | `zim/videos/canadian-prepper_en_winterprepping_2026-08.zim` | That YouTube channel, packaged by Kiwix. |
| Canadian Prepper: Bug Out Roll | 2026-07 | 879 | `zim/videos/canadian-prepper_en_bugoutroll_2026-07.zim` | Same channel. |

Standard adds:

| Title | Snapshot | MB | File | Upstream material |
| --- | --- | --- | --- | --- |
| Ready.gov | 2024-12 | 2,429 | `zim/zimit/www.ready.gov_en_2024-12.zim` | Crawl of ready.gov (FEMA). US government work. |
| The Great Outdoors Q&A | 2026-02 | 142 | `zim/stack_exchange/outdoors.stackexchange.com_en_all_2026-02.zim` | Outdoors Stack Exchange dump. CC BY-SA. |
| Amateur Radio Q&A | 2026-02 | 75 | `zim/stack_exchange/ham.stackexchange.com_en_all_2026-02.zim` | Ham Stack Exchange dump. CC BY-SA. |
| Canadian Prepper: Bug Out Concepts | 2026-08 | 2,886 | `zim/videos/canadian-prepper_en_bugoutconcepts_2026-08.zim` | Channel video. |
| Urban Prepper | 2026-08 | 2,245 | `zim/videos/urban-prepper_en_all_2026-08.zim` | Channel video. |

Comprehensive adds:

| Title | Snapshot | MB | File | Upstream material |
| --- | --- | --- | --- | --- |
| Canadian Prepper: Prepping Food | 2026-07 | 2,160 | `zim/videos/canadian-prepper_en_preppingfood_2026-07.zim` | Channel video. |
| Post Disaster Resource Library | 2024-05 | 644 | `zim/other/zimgit-post-disaster_en_2024-05.zim` | Zimgit book bundle. |
| Hundred Rabbits | 2026-06 | 172 | `zim/zimit/100r.co_en_all_2026-06.zim` | Crawl of 100r.co. Hundred Rabbits publishes the site under CC BY-NC-SA 4.0. |
| Project Gutenberg: Military Science | 2026-03 | 1,200 | `zim/gutenberg/gutenberg_en_lcc-u_2026-03.zim` | Gutenberg LCC class U. Mostly US public domain. |
| CD3WD Appropriate Technology Library | 2025-11 | 581 | `zim/zimit/cd3wdproject.org_en_all_2025-11.zim` | Crawl of the CD3WD collection assembled by Alex Weir. The library mixes public-domain manuals and third-party guides. |

### Education and reference

Essential is one file: Wikibooks, no pictures, `wikibooks_en_all_nopic_2026-01.zim`, 3,100 MB, CC BY-SA.

Standard adds TED-Ed (`ted_mul_ted-ed_2026-09.zim`, 6,381 MB), Wikiversity with images (`wikiversity_en_all_maxi_2026-02.zim`, 2,370 MB, CC BY-SA), and four LibreTexts shelves: math (792 MB, 2026-01), physics (534 MB, 2026-01), chemistry (2,180 MB, 2025-01), biology (2,240 MB, 2025-01).

Comprehensive adds Wikibooks with images (5,400 MB, 2026-01), TED Conference talks (`ted_mul_ted-conference_2026-09.zim`, 18,136 MB), and LibreTexts humanities (3,730 MB, 2025-01), geosciences (1,127 MB, 2026-01), engineering (678 MB, 2025-01), and business (801 MB, 2026-01).

`collections/CATEGORIES-TODO.md` still lists Wikipedia for Schools, a children's Wikibooks shelf, and Khan Academy Kids as not yet in this ZIM catalog. Khan Academy Kids is called out there as a Kolibri channel, not a ZIM.

### DIY and repair

| Tier | Title | Snapshot | MB | Upstream |
| --- | --- | --- | --- | --- |
| Essential | Woodworking Q&A | 2026-02 | 99 | Woodworking Stack Exchange, CC BY-SA |
| Essential | Motor Vehicle Maintenance Q&A | 2026-02 | 321 | Mechanics Stack Exchange, CC BY-SA |
| Standard | DIY and Home Improvement Q&A | 2026-02 | 1,900 | DIY Stack Exchange, CC BY-SA |
| Comprehensive | iFixit Repair Guides | 2025-12 | 3,380 | iFixit, CC BY-NC-SA |

### Agriculture and food

| Tier | Title | Snapshot | MB | Upstream |
| --- | --- | --- | --- | --- |
| Essential | FOSS Cooking | 2026-02 | 24 | Crawl of foss.cooking |
| Essential | Based.Cooking | 2026-08 | 16 | Crawl of based.cooking |
| Standard | Gardening Q&A | 2026-02 | 923 | Gardening Stack Exchange, CC BY-SA |
| Standard | Cooking Q&A | 2026-02 | 236 | Cooking Stack Exchange, CC BY-SA |
| Standard | Food for Preppers | 2025-04 | 98 | Same zimgit file as the survival tier |
| Comprehensive | Learning Self-Reliance: Homesteading | 2026-06 | 3,790 | `zim/videos/lrnselfreliance_en_all_2026-06.zim`, channel video |
| Comprehensive | Project Gutenberg: Agriculture | 2026-03 | 4,300 | Gutenberg LCC class S, mostly US public domain |

### Computing and technology

Essential is DevDocs plus freeCodeCamp, all small: freeCodeCamp (8 MB, 2026-08), Python (4 MB), JavaScript (3 MB), HTML (2 MB), CSS (5 MB). Snapshot months are 2026-07 or 2026-08 except where noted in the file names.

Standard adds Arduino Stack Exchange (247 MB), Raspberry Pi Stack Exchange (285 MB), and DevDocs for Node.js (1 MB), React (3 MB, 2026-02), and Git (2 MB).

Comprehensive adds Electronics Stack Exchange (3,800 MB), Robotics Stack Exchange (233 MB), and DevDocs for Docker (2 MB) and Bash (1 MB, filed under the title "Linux Documentation").

## Maps

Two different pipelines. Both end as PMTiles drawn with MapLibre. Attribution string in `map_service.ts`:

> Protomaps © OpenStreetMap

### Pre-cut United States

`collections/maps.json` lists 50 states, snapshot **2025-12**, grouped into the nine Census regions (Pacific through New England). Every URL is:

```
https://github.com/Crosstalk-Solutions/project-nomad-maps/raw/refs/heads/master/pmtiles/<state>_2025-12.pmtiles
```

Catalog sizes run from Hawaii at 28 MB to California at 1,100 MB. Alaska is 684 MB. There is no DC tile and no territory tile in this file.

The [project-nomad-maps README](https://github.com/Crosstalk-Solutions/project-nomad-maps) says how they were made:

1. Start from the [Protomaps basemap](https://docs.protomaps.com/basemaps/downloads), a vector basemap derived from OpenStreetMap. Protomaps distributes that basemap as an Open Database License produced work. The planet file they cut from is described there as 120 GB and up.
2. State polygons come from the US Census Bureau TIGER/Line shapefile, converted with GeoPandas in `convert_shapefile.py`.
3. `pmtiles extract` cuts one file per state (`extract_states.sh`).

The same README then says the repository as a whole is MIT, copyright 2025 Crosstalk Solutions, LLC. That MIT paragraph and the ODbL paragraph above it do not describe the same thing. The tiles are OSM-derived and stay under ODbL. The scripts and the customized style assets are what the MIT text can cover. Fonts in `basemaps-assets/fonts/` are SIL OFL. Sprites derive from tangrams/icons, MIT.

`downloadBaseAssets()` fetches `base-assets.tar.gz` from that same GitHub repo (fonts, sprites, the style NOMAD's MapLibre renderer uses).

### Live extract of the world, or of one country

For a low zoom world fallback, and for "any country" in the UI, NOMAD does not use the GitHub files. `map_service.ts` reads `https://build-metadata.protomaps.dev/builds.json`, picks a build, and extracts from `https://build.protomaps.com`.

- `world.pmtiles` is zoom 0–5, about 15 MB, extracted once.
- A country extract uses a polygon from Natural Earth 1:50m Admin-0 (`admin/resources/geodata/ne_50m_admin_0_countries.geojson`, public domain), zoom up to 15 by default (`EXTRACT_MAX_ZOOM`).
- The CLI is go-pmtiles 1.30.2, SHA-256 pinned in the Dockerfile for amd64 and arm64.

That is the path behind the website's "entire world, or just the countries you need." The pre-cut catalog is only the 50 states. A full planet file is not stored as one download in `maps.json`. Pulling many countries at zoom 15 is how the disk fills.

OpenStreetMap itself is ODbL 1.0, copyright OpenStreetMap contributors.

## Drug reference and the remedy pages

Three layers, all optional. A new box has none of them until the Medicine tier or the Drug Reference page starts a download.

### openFDA labels

`DrugReferenceService` downloads the openFDA drug-label export. The catalog URL is the manifest `https://api.fda.gov/download.json`. The service then fetches the parts (about 1.7 GB compressed) and indexes them. The in-app doc says the index lands around 8–10 GB and groups products by active ingredient. Search-by-situation matches label text against the condition table. Comparing two drugs shows the two warning sections side by side. It does not compute interactions.

The labels are the manufacturers' text as published by the FDA. NOMAD's own page says this is the label, not medical advice. Automatic content update re-checks whether openFDA's export date moved.

### Condition list

`collections/conditions.json` is NOMAD's own search vocabulary: **36** slugs (pain, headache, cough, and so on) with the phrases to look for inside a label. Version 2026-06-07. No external source is declared. The build regenerates `admin/app/data/conditions.ts` from this JSON (`npm run gen:curated-data` in the Dockerfile) so the image cannot drift from the JSON.

### Herbs and home measures

These are short articles compiled into the image. They are not fetched at install time.

| File | Count | Declared source | License the JSON states |
| --- | --- | --- | --- |
| `collections/natural_remedies.json` | 18 | [NCCIH Herbs at a Glance](https://www.nccih.nih.gov/health/herbsataglance) | Public domain, US government work. Each entry has its own `sourceUrl` on nccih.nih.gov. Version 2026-06-10. |
| `collections/home_remedies.json` | 20 | CDC, NIH/NHLBI, MedlinePlus/NLM, FDA | Public domain, US government works. Per-entry URLs are on `www.cdc.gov`, `medlineplus.gov`, and `www.fda.gov`. Version 2026-06-10. |

NCCIH is the National Center for Complementary and Integrative Health. The entries include a use, a how, an evidence line, and a caution. Examples of the source pages: aloe vera, boswellia, and bromelain on NCCIH; honey-for-cough and oral rehydration on CDC and MedlinePlus.

## Courses (Kolibri)

NOMAD does not pin a Khan Academy URL. The Education Platform container is empty until someone imports a channel.

The Supply Depot doc says: Device → Channels → Import, from Kolibri Studio while online, or from a drive or another Kolibri. After that, lessons, exercises, and progress stay in `storage/kolibri-gen2`.

The marketing site and `admin/docs/getting-started.md` describe that import as Khan Academy, TED talks, and a K-12 curriculum. The FAQ's storage sketch says "Khan Academy courses: ~50 GB." That number is a planning figure in the FAQ, not a file hash in the repo. Channel licenses are whatever Kolibri Studio lists for that channel. Khan Academy's own materials are under Khan Academy's terms.

Wikipedia for Schools is named on the homepage and is still an open item in `collections/CATEGORIES-TODO.md`. It is not one of the pinned ZIMs.

## Models

### Chat and embeddings

Weights are not in the git repo. Ollama pulls them when the operator picks a model. The recommendation list is fetched from `https://api.projectnomad.us/api/v1/ollama/models` and cached at `storage/ollama-models-cache.json`. If that API is down, `admin/constants/ollama.ts` falls back to three tags:

| Tag | Catalog size in the fallback | Notes |
| --- | --- | --- |
| `llama3.1:8b-text-q4_1` | 5.1 GB | Meta Llama 3.1. Weight license is the Llama Community License, not MIT and not Apache. |
| `deepseek-r1:1.5b` | 1.1 GB | DeepSeek-R1. DeepSeek's model license. |
| `llama3.2:1b-text-q2_K` | 581 MB | Meta Llama 3.2. Llama Community License. |

The embedding model is fixed: `nomic-embed-text:v1.5` (Nomic). Vectors go to Qdrant on disk at `storage/qdrant`.

Ollama the program is MIT. That license is the server, not the weights. Any other model the operator pulls (the UI can list the whole Ollama library) keeps that model's license and its size.

Retrieved context is capped by model size in `RAG_CONTEXT_LIMITS` (tighter for 1–3B and 4–8B). The relevance floor default is 0.62, tuned on a 99-question golden set that ships in `admin/tests/eval/`. Those fixtures include short public-domain-style excerpts (Gutenberg titles are named in the fixture filenames) used only as eval distractors. They are not the library the user reads.

### Translation

`install/nomad-translate/fetch_models.py` downloads Firefox translation models from Firefox Remote Settings. NOMAD's README for that proxy says the GitHub repo `mozilla/firefox-translations-models` was archived on 2026-08-21, so they use the same endpoint Firefox uses. Models are MPL 2.0. Default language set is French, Spanish, and German, each direction, about 45–140 MB a language. About 50 languages had a desktop release in both directions when they checked in October 2026. Chinese is skipped because the proxy only accepts two-letter codes and Firefox publishes `zh-Hans` / `zh-Hant`. The proxy is amd64 only. Bergamot's `intgemm` backend has no aarch64 wheel in the build they ship.

## Creator Packs

`collections/creator-packs.json`:

| Id | Creator | Videos | Catalog size | Version |
| --- | --- | --- | --- | --- |
| `project-nomad` | Project NOMAD | 5 | 178 MB | 2026-07 |
| `crosstalk-solutions` | Chris Sherwood | 30 | 2,899 MB | 2026-07 |
| `modern-rogue` | Brian Brushwood | 37 | 5,177 MB | 2026-07 |

License id on every pack: `nomad-creator-pack-1.0`, text in `collections/creator-pack-license.md`. The creators keep copyright. Crosstalk gets a revocable right to host the packs on the official channel only. A person who installs a pack may watch it offline at home. The draft forbids re-hosting, shipping the files with a fork, selling them, or training a model on them. The file says it has not been through legal review.

Downloads are gated. `creator_pack_service.ts` defaults to `https://nomad-packs-worker.chris-556.workers.dev` and sends `CREATOR_PACKS_APP_KEY`. Official release images bake that key in as a Docker build arg. A build from source without the secret hides the packs UI. The key is recoverable from the public image layer. The Dockerfile comment says rotation is a new Worker secret plus a new image.

## Community add-ons

Documented in `admin/docs/community-add-ons.md`. Not maintained by Crosstalk. They build a ZIM on the NOMAD host and register it with `nomad_kiwix_server`.

| Pack | Repo | What it pulls | Result size they quote |
| --- | --- | --- | --- |
| US military field manuals | [jrsphoto/ZIM-military-field-manuals](https://github.com/jrsphoto/ZIM-military-field-manuals) | About 180 public-domain field manuals, PDFs from archive.org, about 2 GB of source | About 2 GB ZIM |
| W3Schools | [kennethbrewer3/ZIM-w3schools-offline](https://github.com/kennethbrewer3/ZIM-w3schools-offline) | A GitHub mirror of the W3Schools tutorials, about 6 GB of source | About 700 MB ZIM |

W3Schools' tutorials are W3Schools' copyright. The add-on is a packaging project. The field-manual pack is the one that states its sources are public domain.

## What the operator adds, with no upstream pin

| Folder | Who writes it | Used by |
| --- | --- | --- |
| `storage/kb_uploads` | Uploaded PDFs, text, docx, images | RAG index in Qdrant. NOMAD's own docs are ingested when the assistant is installed. |
| `storage/books` | The operator's ebooks, plus an empty Calibre database NOMAD seeds | Calibre-Web, File Browser |
| `storage/media` | The operator's video, audio, photos | Jellyfin, File Browser |
| `storage/flatnotes` | Notes typed in FlatNotes | FlatNotes |
| `storage/vaultwarden` | The vault the operator creates | Vaultwarden |
| `storage/homebox` | Inventory the operator types | Homebox |
| `storage/jellyfin` | Jellyfin's config and cache | Jellyfin |
| `storage/kolibri-gen2` | Imported channels and learner accounts | Kolibri |
| `storage/ollama` | Whatever models were pulled | Ollama |
| `storage/translate/models` | Firefox translation models | Translated Library |

File Browser is allowed to see `books`, `maps`, `media`, `kb_uploads`, and `zim`. The seeder comment says vaultwarden, ollama, qdrant, and app databases are left unmounted so the file manager cannot delete them.

## Hosts a connected box will talk to

Pulled from the code paths above. A fully offline box, after the downloads finish and with auto-update off, has no reason to call these.

| Host | When |
| --- | --- |
| `download.kiwix.org` | ZIM bytes |
| `opds.library.kiwix.org` | ZIM update check |
| `api.fda.gov` | Drug-label manifest and parts |
| `build-metadata.protomaps.dev`, `build.protomaps.com` | Planet basemap extract |
| `github.com` / `raw.githubusercontent.com` (Crosstalk-Solutions/project-nomad-maps) | Pre-cut state tiles and style assets |
| `ghcr.io`, Docker Hub (`ollama`, `qdrant`, `mysql`, `redis`, `jellyfin`, `vaultwarden`, `filebrowser`, `linuxserver`, `learningequality`, `excalidraw`, `dullage`, `amir20`) | Container images |
| Ollama's model registry | Weights |
| Firefox Remote Settings | Translation models |
| Kolibri Studio | Course channels, only if the operator imports |
| `api.projectnomad.us` | Model recommendation list, release-note signup, internet-up fallback |
| `benchmark.projectnomad.us` | Score submit and stats, only from the benchmark screen |
| `nomad-packs-worker.chris-556.workers.dev` | Creator Pack bytes, official builds only |
| `1.1.1.1` | Default internet-up probe (`/cdn-cgi/trace`) |
| GitHub API | Update checks, and the other internet-up fallback |
