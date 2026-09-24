# add-edgebox-home-base

> **ACTIVE BUILD**

## Why

Edgebox needs a coherent home for the tools running on a Raspberry Pi 5 with
SSD storage. People should begin with an intention such as “Work with PDFs”
and reach an installed tool, while retaining a searchable application directory
and control over their preferred providers. The current application contains
starter pages and authentication examples, not this product structure.

## What

- Define the `edgebox-home-base` capability and product brief.
- Establish navigation, URLs, terminology, content hierarchy, complete journey
  and interaction coverage, and a shared Storybook/app component contract.
- Record architecture decisions for the catalog, capability routing, preferences,
  identity boundaries, service health, and future storage integrations.
- Give database and interface workers compatible contracts for the next wave.
- Plan focused component, server, and end-to-end verification.

This node delivers design and architecture documents. It does not implement
the proposed runtime behavior. The product deltas remain proposed until their
own implementation nodes land.

## Impact

- Capabilities: ADDED `edgebox-home-base` (proposed product contract).
- ADRs: decisions in `design.md`; eventual fold updates `ARCHITECTURE.md`
  with delivered shape, explicitly distinguishing future boundaries.
- Existing app/auth/demo/schema code is unchanged by this node.
- No new runtime dependencies, migrations, or infrastructure changes here.

## User journey & surfaces

See [the IA](information-architecture.md) and [the interaction inventory](journeys.md).
They cover guest discovery, returning members, provider choice, filtering,
application inspection, failed launches, authentication, passkeys, and operator
health. Each interaction maps to a Storybook surface, route, and focused test.

## Preparation — 2026-09-21

- Upstream: chat DAG `nod-edgebox-home-base`, no inbound dependencies or
  prior committed implementation artifact.
- Authority: user requested autonomous design and development, then explicitly
  said “activate first wave.” Architecture uses Astra; user suspended the
  cross-family rule for this session. Independent review remains required.
- Inputs: root `AGENTS.md`, `README.md`, `package.json`,
  `src/lib/server/db/{schema,index,auth.schema}.ts`, `src/lib/server/auth.ts`,
  `src/hooks.server.ts`, demo login action, `vite.config.ts`, Storybook preview,
  `infrastructure/raspi/services/{compose.yaml,README.md}`, and `PXE-NOTES.md`.
- Host evidence: conductor's read-only SSH inventory this turn confirms seven
  user applications and the supporting services listed in `design.md`.
  Health is a dated observation, not a seed asserting permanent availability.
- Existing OpenSpec, architecture, and learnings records: absent. Minimal
  specification workflow files are established without claiming product delivery.
- Outcome: **revised within scope**. Home uses curated frequent tasks initially;
  pinned/recent usage is deferred instead of silently adding tracking. Catalog
  seeding preserves existing data. PDF signing is described as adding a signature,
  not a legally complete electronic-signature workflow. Health has no implied
  SSO, storage delegation, or container-control authority.
- Important implementation findings: auth currently enables email/password;
  the demo invokes the social-login API for a generic OAuth provider. The identity
  node must verify the correct generic OAuth endpoint and integration behavior.
  PKCE currently relies on the library default; the observed Identikey discovery
  metadata advertises S256 support. Auth integration is not proven by this note.
- References for the change workflow were read from the installed plugin cache
  because `.agents/references` was absent. No dispatch-contract or ladder output
  is invented. Current worktree has substantial untracked starter files; preserve
  them and commit only explicitly owned documents when landing this node.

Review reconciliation, 2026-09-21: the first fresh Astra advise returned
`send-back`. The amended contract makes reset reuse the normal resolver in all
five result states, defines Home search as capability search (J19), and replaces
ambiguous application-detail preference controls with explicit capability links
(J20). Scope/authority are unchanged. Fresh advise remains owed on this revision.

## Out of scope

- Runtime catalog, schema/migrations, seed data: `add-service-catalog`.
- Runtime reusable UI and visual design: `add-edgebox-interface-kit`.
- Runtime routes, preference saving, launching: `add-capability-directory`.
- Runtime reachability checks: `add-service-health`.
- Identikey integration corrections and local passkeys: `add-identikey-passkeys`.
- Integrated Playwright acceptance suite: `add-home-base-e2e`.
- Blob Door/Mjolnir, storage implementation, delegation protocol, per-document
  launch, file picking, automatic Docker discovery, app installation, container
  lifecycle controls, remote configuration, HTTPS/Caddy changes, registration
  lockdown, and memory-cgroup configuration: future intention, not this campaign.
- Pins, activity history, analytics, custom user categories, and global search
  overlays: deferred product enhancements, no implementation commitment here.
