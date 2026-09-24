# Plan: Identikey data-access delegation

## Outcome

Allow a user to grant an installed application narrowly scoped, revocable access
to selected Edgebox data, using Identikey’s verified delegation protocol and the
storage boundary rather than broad filesystem or account credentials.

## Dependencies and discovery

- Requires the delivered storage port and Identikey account integration.
- Obtain and cite the authoritative Identikey delegation specification, endpoint
  metadata, token format, audience/resource rules, consent model, revocation, and
  proof-of-possession requirements. None are inferred in this plan.
- Threat-model malicious applications, token theft/replay, confused-deputy flows,
  stale consent, shared-box users, and offline synchronization.

## Intended flow

1. User starts a capability involving selected blobs.
2. Edgebox names the exact application, data, actions, and duration requested.
3. User grants or denies through the verified Identikey flow.
4. The application receives only the protocol-defined scoped authority.
5. Access is audited and can be revoked; expiration/failure returns to Edgebox
   without losing or silently widening consent.

## Vertical slices

- [ ] **Protocol dossier and threat model:** Record authoritative contracts,
      security properties, open questions, and a testable trust boundary.
- [ ] **Consent interaction model:** Build Storybook states for request, deny,
      approve, partial scope, expiration, revocation, and provider failure.
- [ ] **Delegation adapter:** Implement validation/exchange behind a server-only
      interface with controlled fake-provider conformance tests.
- [ ] **Single read-only pilot:** Delegate one selected blob to one trusted test
      application; audit and revoke it before adding writes.
- [ ] **Data-bearing capability launch:** Only after the pilot, connect a real
      capability such as document signing with explicit result-storage semantics.

## Acceptance

- Tokens/claims are issuer-, audience-, subject-, scope-, expiry-, and replay-checked
  exactly as the verified protocol requires.
- Denial or provider outage never falls back to broad access.
- Revocation and expiration are observable and covered by deterministic tests.
- No delegation secret or raw user blob is logged.

## Non-goals

Inventing a proprietary delegation protocol, granting whole-account storage by
default, application SSO, or implementing before authoritative specs are available.
