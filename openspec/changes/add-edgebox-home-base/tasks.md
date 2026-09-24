# Tasks

- [x] Observe code, deployment notes, and the current host inventory.
- [x] Define the product brief, IA, terminology, URLs, and content priorities.
- [x] Map all intended interactions to Storybook, app, and test surfaces.
- [x] Record architecture decisions and contracts for catalog/interface descendants.
- [x] Add scenario-based product deltas without claiming runtime delivery.
- [x] Record preparation, authority, non-goals, and descendant handoffs.
- [x] Fresh advise after preparation — amended contract accepted in `reviews/2026-09-21-advise-2.md`.
- [x] Reconcile J08 reset behavior with ADR 1 and the provider-resolution delta; specify default, sole, multiple, zero-provider, and unavailable-default reset cases with focused story/server coverage.
- [x] Define Home search destination/scope/query behavior and application-detail provider/default controls (or explicit links to the existing capability flow), with journey IDs and Storybook/app/test mappings.
- [x] Address review findings and verify document consistency and formatting.
- [x] Land the reviewed architecture artifact and hand off ready descendants — accepted in `reviews/2026-09-21-advise-2.md`; `add-service-catalog` and `add-edgebox-interface-kit` are ready to prepare.

## Descendant handoffs

- `add-service-catalog` and `add-edgebox-interface-kit` can prepare in parallel
  after this artifact is reviewed and landed. They must consume the same DTOs
  and display rules in `design.md` before owning separate files.
- `add-capability-directory` waits on both descendants. It uses current auth
  session primitives; preference mutation remains server-authorized.
- `add-service-health` waits on catalog and directory.
- `add-identikey-passkeys` waits on this design and the interface kit; it retains
  its own independent architecture/security review and preparation.
- `add-home-base-e2e` follows directory, health, and identity. It integrates the
  existing focused tests rather than retesting every component state.
