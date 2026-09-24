# Plan: Identikey-first identity and local passkeys

## Outcome

Identikey establishes an Edgebox account. The same authenticated user may enroll,
rename, authenticate with, and remove local passkeys under explicit recovery and
recent-authentication rules.

## Required discovery before implementation

- Verify the installed Better Auth generic OAuth and passkey APIs against their
  current official documentation and installed types.
- Exercise `auth.identikey.me` discovery and callback behavior with a registered
  development client; do not infer claims beyond observed metadata.
- Decide the stable production HTTPS origin/RP ID before generating real passkeys.
- Determine the provider’s immutable subject, verified-identity signal, account
  linking behavior, and supported delegation relationship. Email equality is not proof.

## Decisions already made

- Identikey is the account-establishment path; remove public password signup/login
  from product navigation after migration safety is established.
- Generic OIDC uses discovery, PKCE, nonce/issuer/JWKS verification, and only
  scopes advertised by the provider.
- Preserve existing accounts; never silently merge identities.
- Passkeys belong to an authenticated Identikey-linked account.
- Last-passkey removal requires recent authentication, confirmation, and a verified
  Identikey fallback; otherwise prevent it.
- Plain LAN HTTP shows an unsupported secure-context explanation.

## Vertical slices

- [ ] **Prove Identikey callback:** Replace the demo login route with controlled
      Identikey redirect/callback/error states and safe local return paths. _Modifies auth surface._
- [ ] **Migrate account entry:** Remove public email/password product flows without
      deleting existing data or creating lockout. _Requires explicit migration tests._
- [ ] **Enroll and use a passkey:** Add Better Auth schema via generated migration,
      reuse `LoginPanel`/`PasskeySettings`, and test with Playwright virtual authenticators.
- [ ] **Manage credentials safely:** Rename/remove with ownership, recent-auth, final
      credential recovery, cancellation, and failure tests. _Reuses passkey components._

## Acceptance

- Controlled-boundary tests cover callback rejection, cancellation, replay/state
  failure, foreign return paths, account linking, and provider outage.
- Virtual-authenticator E2E proves Identikey-established account → enroll → sign
  out → passkey sign-in to the same account.
- Secrets/tokens never enter rendered data, logs, or test fixtures committed to Git.

## Non-goals

Application SSO, delegated data access, operator roles, Pi TLS configuration,
recovery codes, organization management, and relying on the production IdP in CI.
