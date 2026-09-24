# Plan: Blob Door/Mjolnir storage boundary

## Outcome

Provide durable personal blob storage with local caching and remote synchronization
behind an Edgebox-owned interface, without coupling product routes to Mjolnir
deployment details or pretending File Browser is delegated user storage.

## Discovery gate

Before code, inspect the current Mjolnir/Blob Door repository and document its
actual APIs, identity model, object naming, integrity guarantees, sync/conflict
semantics, encryption, quotas, deletion behavior, and minimum Pi resources. If
the Pi cannot run it safely, define a compatible lightweight local backend rather
than changing the application contract.

## Proposed application boundary

The interface should support storing, reading, listing, and deleting opaque blobs
plus bounded metadata; stable blob IDs; streaming; integrity verification; and
explicit ownership. Synchronization state is storage metadata, not user-facing
application health. Backend credentials never reach routes or delegated clients.

## Vertical slices

- [ ] **Document the verified Blob Door contract:** Record upstream APIs, resource
      needs, failure modes, and compatibility assumptions. _No product code._
- [ ] **Define/test the storage port:** Add backend-neutral contract tests for
      ownership, streaming, integrity, retries, deletion, and unavailable backend.
- [ ] **Implement local backend:** Provide a safe SSD-backed implementation with
      quotas and atomic writes for development/small boxes.
- [ ] **Implement Blob Door adapter:** Run the same contract suite and add bounded
      cache/sync state without leaking backend concepts into routes.
- [ ] **Add minimal file surfaces:** Only after both backends pass, design storage
      browsing/picking in Storybook and routes.

## Acceptance

- No path traversal, cross-user reads, unbounded buffering, or silent corruption.
- Backend choice is configuration, not a fork of product logic.
- Backup, restore, deletion, offline behavior, and synchronization conflict policy
  are documented and tested before storing irreplaceable data.

## Non-goals

Identikey delegation, document signing workflows, collaborative editing, arbitrary
filesystem access, or committing to Mjolnir before its measured Pi viability.
