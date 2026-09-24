# Edgebox roadmap

Updated 2026-09-24. This is the durable dependency map, not a date promise.
Living specs describe delivered behavior; files in `docs/plans/` describe work
that has not yet shipped.

## Delivered

- [x] Curated SQLite service catalog and migrations
- [x] Storybook-first interface kit and component tests
- [x] Capability-first Home, directories, details, launches, and preferences
- [x] Minimal deterministic directory Playwright journey
- [x] Raspberry Pi service stack documentation
- [x] Raspberry Pi image-builder foundation

## Product completion path

1. [Service health and operator view](plans/service-health.md)
2. [Identikey-first identity and local passkeys](plans/identity-passkeys.md)
3. [Integrated end-to-end proof](plans/integrated-e2e.md)
4. [Deploy Edgebox to the Pi](plans/edgebox-deployment.md)

Service health and identity can proceed independently. Integrated E2E requires
both. Deployment follows a green integrated proof and trusted-HTTPS decision.

## Data platform path

1. [Blob Door/Mjolnir storage boundary](plans/blob-storage.md)
2. [Identikey data-access delegation](plans/identikey-delegation.md)
3. A later change may add file-aware capabilities such as “Sign this document.”

Storage must expose a proven local interface before delegation is implemented.
Delegation must be specified and threat-modeled before any third-party app
receives a user file or token.

## Operational follow-ups

- Establish trusted HTTPS before real Vaultwarden or WebAuthn use.
- Create initial Forgejo/Vaultwarden/Vikunja accounts, rotate Stirling’s initial
  password, and disable public registration.
- Enable/test memory cgroups in the image rather than relying on ignored Compose
  limits.
- Add backup/restore validation before treating the box as durable personal storage.

## Completion definition

The initial home-base release is complete when a user can authenticate with
Identikey, optionally enroll/use a passkey, browse and launch capabilities,
observe honest service status, save preferences, and pass deterministic integrated
tests against a deployable HTTPS configuration on the Pi.
