# Plan: integrated end-to-end proof

## Outcome

A small deterministic suite proves the seams between identity, catalog,
preferences, health, and the reused Storybook components without duplicating
component-level state coverage.

## Dependencies and fixtures

- Requires delivered service health and Identikey/passkeys.
- Reuse the disposable migrated SQLite and isolated SvelteKit server pattern in
  the existing Playwright configuration.
- Use controlled OIDC, WebAuthn virtual authenticator, and health fixtures that
  exist only in the test process. Production must have no test-header login bypass.

## Integrated journeys

- [ ] **Discover:** Home → search/filter → reload/back → application detail →
      approved external link, including one narrow viewport and no-results recovery.
- [ ] **Prefer:** Controlled login → choose/save provider → reload → correct launch
      → reset. Prove cross-user isolation in focused server tests, not a second long E2E.
- [ ] **Recover:** Unavailable preferred app → open an alternative once → verify
      original saved preference remains unchanged.
- [ ] **Identity:** Identikey boundary → enroll passkey → sign out → passkey login
      with a virtual authenticator.

## Acceptance

- Each journey has one clear ownership boundary and deterministic fixture setup.
- External links are asserted but never contacted.
- Failures retain trace/screenshot artifacts outside source control.
- `bun run test`, `bun run test:e2e`, Storybook build, production build, and lint pass.

## Non-goals

Exhaustive browser matrices, load testing, visual regression infrastructure,
production IdP availability, and live Pi service mutation.
