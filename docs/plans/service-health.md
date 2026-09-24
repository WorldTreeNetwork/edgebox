# Plan: service health and operator view

## Outcome

Edgebox records bounded reachability observations for approved catalog endpoints
and gives authorized operators a useful `/system` view without becoming a
container-management or arbitrary-request service.

## Dependencies and reuse

- Reuse catalog endpoints/DTOs, `ServiceStatus`, and `SystemOverview`.
- Requires the delivered capability directory; independent of passkeys.
- Add a reviewed Drizzle migration for latest observations if persistence is used.

## Decisions

- Probe only enabled catalog endpoints explicitly marked for health observation.
- Allow HTTP(S) only; reject credentials, redirects to new destinations, arbitrary
  user URLs, and SSH endpoints.
- Start with conservative exact limits: short timeout, small response-byte cap,
  bounded concurrency, deduplication, cache TTL, and manual-refresh cooldown.
  Pin numeric values after measuring the local services and test every limit.
- Treat configured expected responses—including authentication redirects or 401
  where appropriate—separately from generic success.
- Preserve the previous observation on refresh failure and mark it stale.
- Authorize `/system` through an explicit deployment-configured allowlist of
  stable Better Auth user IDs, default empty.

## Vertical slices

- [ ] **Observe one configured endpoint:** Add the bounded checker and focused
      timeout, redirect, byte-limit, and URL-policy tests. _Reuses catalog endpoints._
- [ ] **Persist/display honest state:** Record unknown/online/unavailable/stale
      with timestamps and expose it in existing catalog DTOs. _Modifies catalog adapter._
- [ ] **Operator System page:** Compose `SystemOverview` with server-enforced
      operator filtering and refresh feedback. _Reuses delivered component._
- [ ] **Recovery journey:** Test an unavailable preferred provider without silent
      preference replacement. _Reuses capability detail._

## Acceptance

- Directory rendering never waits on a live probe.
- Guests and ordinary members cannot enumerate infrastructure or trigger probes.
- The checker cannot be turned into SSRF through query/form input.
- Focused tests cover every bound and a deterministic E2E covers stale/failure UI.

## Non-goals

Docker actions, restart buttons, log streaming, resource metrics, alerting,
historical monitoring, and probing live services in CI.
