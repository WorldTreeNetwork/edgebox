# Edgebox architecture

This is the durable map of Edgebox. It distinguishes shipped behavior from
accepted direction. Detailed product decisions and interaction contracts live in
[`openspec/changes/add-edgebox-home-base/`](openspec/changes/add-edgebox-home-base/).

## Product

Edgebox is the home base for software running on a small edge computer. It leads
with capabilities—“Manage tasks,” “Work with PDFs,” “Host code”—and treats the
application providing each capability as a replaceable implementation detail.
Users can also browse the installed application directory directly.

The first target is a Raspberry Pi 5 with SSD-backed persistent data. Guests may
browse explicitly public catalog entries. Signed-in members may save their own
preferred providers. Operators may inspect infrastructure, but operator access is
never inferred from LAN presence, email address, or client-side UI state.

## Delivered shape

- SvelteKit/Svelte application using shared Storybook-developed components.
- SQLite through Drizzle with committed migrations applied at process startup.
- Curated relational catalog: categories, capabilities, applications, endpoints,
  provider associations, and member preferences.
- Capability-first Home, capability/application directories, detail pages,
  approved external launches, URL-backed filters, and member preference actions.
- Better Auth tables and an initial Identikey generic-OIDC configuration. The
  current production-quality identity journey is not yet complete.
- Reproducible Raspberry Pi image-builder foundation and a documented Compose
  service stack.

Living behavior is authoritative in [`openspec/specs/`](openspec/specs/).
Archived implementation changes are in
[`openspec/changes/archive/`](openspec/changes/archive/).

## Boundaries and decisions

### Capabilities and applications

Categories organize discovery; capabilities describe user intentions;
applications implement capabilities; endpoints are concrete launch or observation
targets. Provider resolution is: eligible member preference, eligible curated
default, sole eligible provider, chooser, then no-provider state. Unavailability
never silently changes a saved preference.

### Server authority

The server applies visibility before constructing DTOs. It derives preference
ownership from the authenticated session and validates the capability/provider
association and approved HTTP(S) endpoint. UI components receive display data and
emit intent; they do not authorize users or manufacture URLs.

### Launches are transparent

Initial launches are labeled links to catalog-approved entry pages. Edgebox does
not imply SSO, pass user identifiers, attach credentials, or transfer files.
Future data-bearing launches require a separate delegated-access contract.

### Health is observation, not control

Health checks may observe only fixed approved endpoints with strict time,
concurrency, redirect, and response bounds. Reachability is distinct from setup
readiness and container health. Edgebox is not a Docker control plane.

### Identity

Identikey establishes the account; local passkeys authenticate that same account
after enrollment. Password-based demo registration is temporary. Account linking
must never rely on email equality alone. WebAuthn requires a stable trusted HTTPS
origin outside localhost development.

### Storage and delegation

Blob Door/Mjolnir is the intended storage direction, with local caching and
remote synchronization when the hardware can support it. Storage APIs, consent,
scopes, and Identikey delegation remain future contracts. The current File
Browser integration is an external application launch, not personal delegated
storage.

### Deployment

Application state belongs on persistent SSD-backed paths. Builds produce a Node
artifact containing Drizzle migrations. Deployment must add trusted HTTPS before
real Vaultwarden or passkey use, retain backups, avoid baked secrets, and validate
services after restart. Raspberry Pi image decisions live under
[`infrastructure/raspi/`](infrastructure/raspi/).

## Dependency direction

```text
catalog + shared interface
          ↓
capability directory (delivered)
    ┌─────┴────────┐
service health   Identikey + passkeys
    └─────┬────────┘
    integrated E2E
          ↓
    Edgebox deployment

Blob storage → Identikey delegation → data-bearing capability launches
```

## Rules for future agents

1. Read this file, [`docs/ROADMAP.md`](docs/ROADMAP.md), and the relevant plan.
2. Verify living specs before treating an archived proposal as current behavior.
3. Use migrations for every schema change; never use schema push as workflow.
4. Build reusable interactions in Storybook from shadcn-svelte or comparable
   accessible headless primitives, then reuse those exact components in routes.
5. Keep live Pi/OIDC dependencies outside deterministic CI.
6. Do not broaden a plan’s explicit non-goals without recording a new decision.
