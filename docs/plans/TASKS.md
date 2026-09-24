# Build tasks: remaining Edgebox work

Generated from: `openspec/changes/add-edgebox-home-base/design.md`  
Date: 2026-09-24

## Product completion

- [ ] **Service observation:** Deliver bounded health checks and the operator
      System view. _Reuses catalog, `ServiceStatus`, and `SystemOverview`._
- [ ] **Identikey sign-in:** Replace demo account entry with verified OIDC and safe
      return/error flows. _Modifies existing auth routes; reuses `LoginPanel`._
- [ ] **Local passkeys:** Enroll, authenticate, rename, and safely remove passkeys.
      _Reuses `PasskeySettings` and `PasskeyRow`; depends on Identikey sign-in._
- [ ] **Integrated proof:** Add four seam-focused E2E journeys. _Depends on health
      and identity; reuses the disposable SQLite Playwright harness._
- [ ] **Pi deployment:** Package, stage, secure with HTTPS, validate, and add to the
      reproducible image profile. _Depends on integrated proof._

## Data platform

- [ ] **Verify Blob Door:** Document real APIs, integrity/sync semantics, and Pi
      viability. _Research task; no implementation assumption._
- [ ] **Storage contract and backends:** Implement/test a backend-neutral port,
      local SSD backend, and Blob Door adapter. _Depends on verified contract._
- [ ] **Verify Identikey delegation:** Produce protocol dossier and threat model.
      _Research task; depends on identity and storage boundaries._
- [ ] **Read-only delegation pilot:** Grant/revoke one selected blob to one test
      app. _Depends on verified delegation adapter._
- [ ] **Data-bearing capability:** Implement one explicit file workflow only after
      the pilot proves scoping and result storage.

## Review

- [ ] Review each plan at its execution frontier against current upstream docs,
      installed package types, living specs, and Pi state before activation.
