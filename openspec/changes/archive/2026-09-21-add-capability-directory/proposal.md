# add-capability-directory

> **ACTIVE BUILD**

## Why

The catalog and reusable interface kit are delivered, but Edgebox still shows the
Svelte starter page. This change composes those existing contracts into the
capability-first home, searchable directories, details, provider choice, and
member preference flows that make the box useful.

## What

- Add the real application shell and public Home, capability, and application routes.
- Preserve search/filter state in GET query parameters and show honest empty states.
- Resolve providers and expose only catalog-approved external launch links.
- Let authenticated members save or reset their own preferred provider.
- Add focused server/component integration tests and a small Playwright discovery flow.

## Impact

- Capabilities: ADDED `capability-directory`; consumes delivered `service-catalog`
  and `edgebox-interface` without changing their ownership boundaries.
- ADRs: none; follows accepted `add-edgebox-home-base` ADRs 1, 3, and 4.
- No schema migration or new runtime dependency is expected.

## User journey & surfaces

A guest lands on Home, searches or selects an action, inspects its resolved app,
and opens a catalog-approved application in a labeled new tab. A user who knows
the app can browse/filter Applications and follow its capability links. A member
can choose an alternate app once, save it as preferred, or reset to the ordinary
resolver. Empty, unconfigured, and unavailable states keep navigation and recovery.

## Preparation — 2026-09-21

- Upstream artifacts: accepted home-base architecture, delivered living specs
  `service-catalog` and `edgebox-interface`, migrations through `0002`, and green
  catalog/component result records.
- Current code: catalog DTO/repository and Storybook-proven components exist;
  root and demo routes remain scaffold UI. Dependencies are usable.
- Authority: the user explicitly invoked `$run add-capability-directory`, within
  the previously authorized campaign and non-goals.
- Reconciliation outcome: **still valid**. This node owns composition and route
  behavior only. Health remains unknown; identity/passkeys remain separate.

## Out of scope

- Active reachability checks and operator System data: `add-service-health`.
- Identikey correction, password-flow removal, and passkeys: `add-identikey-passkeys`.
- Blob Door, file delegation, application SSO, and document transfer: future intention.
- Container control, app installation, Caddy/TLS, registration lockdown, and Pi mutation.
