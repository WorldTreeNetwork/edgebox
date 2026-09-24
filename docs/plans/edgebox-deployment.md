# Plan: deploy Edgebox to the Raspberry Pi

## Outcome

Run the tested Node application on the Pi behind a stable trusted HTTPS origin,
with persistent SQLite, startup migrations, logs, backups, health verification,
and a rollback path.

## Dependencies

- Integrated E2E is green.
- A trusted DNS/HTTPS approach and production RP origin are selected.
- The existing service stack remains intact and backed up.
- Image-builder and first-boot work under `infrastructure/raspi/image/` is the
  source for reproducible deployment, not ad hoc mutation alone.

## Vertical slices

- [ ] **Package the app:** Produce a pinned Node build containing `drizzle/`, a
      non-root service definition, environment template, and persistent data path.
- [ ] **Stage safely:** Back up `/home/duke/services/edgebox/data`, deploy alongside
      existing services, run migrations, and verify on a non-public listener.
- [ ] **Add stable HTTPS:** Configure DNS/Caddy, trusted certificates, secure
      cookies, callback URL, and WebAuthn RP origin; keep direct port bootstrap-only.
- [ ] **Cut over and observe:** Enable restart policy, log rotation, readiness,
      backup/restore smoke test, and rollback to the prior artifact.
- [ ] **Harden onboarding:** Rotate Stirling credentials, create initial accounts,
      disable public registrations, and verify Vaultwarden only through trusted HTTPS.
- [ ] **Bake reproducibility:** Feed the service into the image/first-boot profile
      and verify memory cgroups, secrets injection, and clean-image validation.

## Acceptance

- Reboot starts Edgebox, applies pending migrations once, and serves HTTPS.
- Identikey callback and passkeys use the registered production origin.
- Existing File Browser/media/PXE services remain reachable and unchanged.
- Backup restoration and application rollback are exercised, not merely documented.
- No default credentials or secrets exist in Git, image layers, manifests, or logs.

## Non-goals

Public-internet exposure, destructive disk provisioning, replacing the current
service stack, automatic major upgrades, or deploying unfinished delegation/storage.
