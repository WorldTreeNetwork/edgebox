# Architecture and product brief

Status: proposed runtime architecture; activated document work, awaiting an
independent Astra reader. This is a dependency contract, not a claim of delivery.

## Product brief

Edgebox is the everyday home for a household or small group using a shared edge
computer. Its main job is to get a person from “I want to…” to the right installed
tool with little repeated decision-making. The owner also needs an accurate
directory of what is installed and a bounded view of service availability.

Primary users are returning members and the operator. Guests may browse the
intentionally public application directory on the network that can reach Edgebox;
preferences and account surfaces require a session. Public directory access is
an explicit exposure choice: it is not a claim that being on a LAN authenticates
the visitor. Do not publish infrastructure rows, private application rows,
credential/configuration data, or member preferences to guests.

The first release succeeds when users can find an action or application, inspect
its provider and availability, open it, and save a default provider after signing
in. Account identity does not automatically sign users into other installed apps.
Initial capability launches open application entry pages; documents and access
tokens are not passed through. “My storage” is a future integration, not a
functioning file view created by linking File Browser.

Visual direction: a calm personal utility. Lead with short verb phrases and
recognizable categories, then provider identity and honest state labels. Use
shared Tailwind tokens, restrained color, visible focus, and ordinary readable
type. Dense diagnostics belong on System. Avoid a decorative dashboard of
unrelated statistics. Interface-kit work owns exact visual choices and stories.

## ADR 1 — Capabilities resolve to installed applications

Decision: model categories, capabilities, applications, and endpoints separately.
Categories organize finding; capabilities describe intentions; applications
provide capabilities; endpoints define concrete destinations. A category filter
never selects an application on the user's behalf.

An application launcher asks “which product?” first and makes people remember
which tool performs a job. Edgebox leads with “Manage tasks” or “Work with PDFs,”
shows the chosen provider, and offers “Choose another app.” The directory remains
one primary navigation item for users who know exactly which application they want.

Provider resolution is deterministic:

1. Consider installed, enabled applications whose visibility the request permits
   and which have an enabled, validated HTTP(S) launch endpoint.
2. For signed-in users, prefer their saved association if still eligible.
3. Otherwise use the curated capability default if eligible; otherwise use the
   sole eligible provider, or present the chooser when several remain.
4. An unavailable preferred/default provider produces a recovery choice, never
   a silent switch or a permanent preference change. Unknown/stale status allows
   launch with honest wording. A known unavailable service may still be opened
   through an explicit “Try opening anyway” link.
5. No eligible provider means an explanatory empty state with a directory link.

“Use default” removes only the signed-in user's saved association, then runs
this same resolver. The resulting display is the eligible curated default, the
sole eligible provider when no default is eligible, the chooser when several
remain, or the no-provider state when none remain. An unavailable resolved
default retains step 4's recovery choices; resetting never silently selects a
different healthy app. Failed reset preserves the stored preference and its UI.

`unavailable` is evidence from a reachability check, not proof the app is broken.
An HTTP check failure can result from network position or authentication.

Home search is a labeled GET form targeting `/capabilities` with the `q` query
parameter. It searches capability labels/summaries and associated visible app
names/summaries, returning capability cards. Submit trims the query; empty input
opens the unfiltered capability index. Reload/back preserve the submitted query.
It is not a combined app-and-capability result surface; users wanting only apps
can follow the Applications navigation link. J19 owns its story/test mapping.

Application details link each associated capability to
`/capabilities/[capability]`. They have no inline preference/default mutation
controls. A multi-capability app has one labeled link per capability; a zero-
capability app has none. Guests may follow the same visible links and encounter
the existing sign-in gate only if saving a preference. These links neither
preselect the originating app nor change a preference. J20 maps this behavior.

## ADR 2 — Curated relational catalog in existing SQLite

Keep the existing Drizzle/SQLite runtime, `DATABASE_URL=local.db` default,
WAL/foreign-key setup, and startup migrations. All schema changes receive reviewed
generated migrations and metadata. Seed known inventory using reviewed migration
data with stable identifiers; future migrations insert/update only intentional
fields. Startup never restores defaults over user preferences or operator edits.

Catalog node owns `src/lib/server/db/` and its migration artifacts. Interface-kit
node owns its UI and stories and must not import the database. They agree on
plain serializable DTOs; server adapters return them. Decide the shared type-file
owner during wave preparation so both workers never edit the same file.

| Concept              | Key fields / constraints                                                                                                                                                             |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Application          | Stable slug ID, name, plain-text summary, kind `application` or `infrastructure`, visibility `public`, `member`, or `operator`, enabled flag; no credentials                         |
| Category             | Stable slug ID, label, display order; curated initially                                                                                                                              |
| Application category | Unique application/category pair; supports several groupings                                                                                                                         |
| Capability           | Stable slug ID, verb label, summary, category ID, display order, nullable curated default application ID                                                                             |
| Provider association | Unique capability/application pair, nullable launch endpoint reference; default and preferred providers must reference a valid association                                           |
| Endpoint             | Stable ID, application ID, purpose `launch`, `health`, or `ssh`, URL/address, enabled flag; SSH endpoints are informational and never HTTP-fetch targets                             |
| Preferred provider   | Unique user/capability pair; user FK to Better Auth, provider association FK; user deletion cascades; removal of provider clears preference or yields an explicit unavailable result |
| Health observation   | Application/endpoint ID, state, checked-at time, optional bounded diagnostic code; latest snapshot only, introduced by health node                                                   |

Use relational constraints for keys and associations; enforce any remaining
cross-record validity in the repository and test it. Preserve existing auth
tables. Do not drop the starter `task` table or its rows merely because the UI
no longer needs it; any retirement requires evidence and an explicit migration.
Do not write imaginary versions, ports, readiness, or capabilities for entries
whose values are unknown. Unknown endpoint means no launch action.

Proposed component contracts, finalized during descendant preparation:

```ts
type HealthState = 'unknown' | 'online' | 'unavailable' | 'stale';
type Viewer = 'guest' | 'member' | 'operator';
type HealthSummary = {
	state: HealthState;
	checkedAt: string | null; // ISO timestamp
};
type ApplicationSummary = {
	id: string;
	name: string;
	summary: string;
	categoryIds: string[];
	capabilityIds: string[];
	launchUrl: string | null; // already policy-validated by server
	health: HealthSummary;
	setupNotice: string | null;
};
type CapabilitySummary = {
	id: string;
	label: string;
	summary: string;
	categoryId: string;
	providers: ApplicationSummary[];
	preferredProviderId: string | null;
	defaultProviderId: string | null;
};
```

DTOs contain display data only; never raw auth records, secrets, filesystem paths,
container environment, or arbitrary raw HTTP error bodies. No UI component
decides whether a caller is authorized. Filtering happens before DTO construction.

## Initial inventory and capability mapping

Evidence: checked-in deployment notes plus read-only SSH observations on
2026-09-21 supplied by the conductor. Listed ports are observed LAN launch
addresses, not a guarantee of future liveness. Fresh databases start health as
unknown until checked. Persist the inventory source/date in seed commentary.

| Application  | Observed entry point                                                        | Initial capability              | Category / special state                                                       |
| ------------ | --------------------------------------------------------------------------- | ------------------------------- | ------------------------------------------------------------------------------ |
| Forgejo      | `http://192.168.0.90:3000`                                                  | Host code                       | Development; SSH `2222` shown separately                                       |
| Vaultwarden  | `http://192.168.0.90:8222`                                                  | Manage passwords                | Personal; setup needed: trusted HTTPS before real credentials                  |
| Vikunja      | `http://192.168.0.90:3456`                                                  | Manage tasks                    | Productivity                                                                   |
| Stirling PDF | `http://192.168.0.90:8082`                                                  | Work with PDFs; Add a signature | Documents; verify signing tool availability before advertising it as supported |
| File Browser | `http://192.168.0.90:8080`                                                  | Browse files                    | Files; its own access controls, not personal delegated storage                 |
| Navidrome    | `http://192.168.0.90:4533`                                                  | Listen to music                 | Media                                                                          |
| Jellyfin     | Caddy `movies.local` configuration observed; launch URL awaits verification | Watch video                     | Media; endpoint unconfigured until verified                                    |

“Add a signature” means placing a signature in a PDF if supported by the deployed
Stirling build; it does not promise recipient workflows, identity verification,
certificate signing, audit trails, or legal enforceability. Until verified,
keep the capability defined but unassociated/disabled and show “No app available.”
Do not make verification of that integration a prerequisite for PDF browsing.

Supporting inventory, visible only to an authorized operator: Radarr, Sonarr,
Lidarr, SABnzbd, Flaresolverr, Transmission, Prowlarr, Gluetun, Caddy, dnsmasq,
Docker, and Tailscale. Store unknown endpoints as null. Gluetun's unhealthy
container observation is diagnostic evidence, not an HTTP health measurement;
the first health checker cannot claim to reproduce Docker's health status.
Container administration and media-stack configuration remain out of scope.

## ADR 3 — Server owns identity, visibility, and preference mutations

Reuse Better Auth session lookup. An authenticated user may read/write only
their own preferences; derive user ID from the server session, never a posted
ID. Validate capability/provider membership and endpoint eligibility at mutation
time. Protect mutations using the framework's same-origin/CSRF contract.

Guests see only curated public application data. Members gain private preferences
and member-visible apps. Operator-only rows/routes require an explicit operator
authorization rule; do not infer operator from email, account order, network
address, or client UI state. Initial operator assignment is a deployment-time
allowlist of stable local Better Auth user IDs read from server configuration,
default empty, with no role-management UI. The catalog/interface nodes do not
need to implement operator provisioning to complete their own acceptance.

Identity node must replace the demo login surface with Identikey-first login,
verify the generic OAuth integration, and remove public password-signup/login
as an unintended alternate account-establishment path. Preserve existing account
data and avoid silent account merging. Provider linking is explicit and verified;
email equality is not identity proof. Inspect library behavior before authoring
the identity implementation contract; no unsupported linking API is prescribed.

Enrollment requires a verified Identikey-linked account and a fresh session;
local passkeys authenticate that same account on subsequent visits. WebAuthn
uses Edgebox's stable HTTPS RP origin (localhost is the development exception).
On plain LAN HTTP show the unsupported-context explanation, not a broken
enrollment button. Do not change Pi TLS configuration as part of this campaign.

Passkey metadata may be renamed; duplicate display names are permitted but
disambiguated by created/last-used dates. Removal requires confirmation and
recent authentication. Last-passkey removal is allowed only when a verified
Identikey recovery/sign-in path remains and the user explicitly acknowledges
using it next time; otherwise prevent removal. Signing out invalidates the
Edgebox session, not sessions in external applications. Expired sessions retain
a same-origin relative return path; reject external return URLs.

## ADR 4 — Launches are transparent links; health is bounded observation

Normal app opens use catalog-validated HTTP(S) links in a new tab with
`rel="noopener noreferrer"`; label that behavior. Credentials, token material,
file paths, and user identifiers are never added to the destination. User query
input cannot become an external launch target or health-check URL. Display the
provider name and hostname before opening. SSH addresses are copyable text in
details, separate from the web launch control.

Health checks run server-side for fixed approved catalog endpoints only; enforce
scheme/host/port policy and reject credentials in URLs. Do not follow redirects
to new destinations. Timeouts, bounded concurrency, deduplication, response-byte
limits, a short cache, and a minimum manual-refresh interval bound Pi work.
Health checks never block the main catalog page. Implementation node sets and
tests exact limits after observing endpoint behavior. Do not treat every
authenticated redirect or HTTP 401 as a definitive outage; define expected
responses per configured endpoint. Guests cannot initiate unrestricted probes.

Reachability and setup readiness are independent. Vaultwarden can be reachable
and still need trusted HTTPS. The launch UI carries that notice, offering a
clear “Open setup” action, without asserting credentials are ready to use.
Health shows “Last checked …” and stale/unknown labels, never a fabricated
green status. HTTP reachability cannot measure free disk, memory, container
restarts, or the security posture of a service.

## ADR 5 — Storage and delegation stay future boundaries

Catalog launch takes a capability ID and returns a choice of approved app links.
It neither reads a document nor grants access. Future Blob Door integration must
add its own storage/delegation contract, consent, and scoped authorization;
there is no placeholder filesystem backend in this wave. Keep that future work
out of UI props and catalog/auth tables until its protocol is known.

## Verification boundaries and rollout

Storybook is the reusable-component development surface. Start custom
interactions from shadcn-svelte or comparable headless primitives; preserve
keyboard/focus semantics and use app CSS. Component props and callbacks have no
server dependencies. Storybook stories express product states, then the app uses
those exact components. Browser Vitest tests validate meaningful interactions;
stories use accessibility checks. Do not duplicate a story interaction as an
identical component test.

Server tests focus on migrations/seeds, audience filtering, preference isolation,
provider resolution, URL policy, and health failure boundaries. Playwright's
small integrated suite covers discovery/filter/details, authenticated preference
and launch, unavailable-provider recovery, and passkey enrollment/login where
browser support permits. CI uses a disposable migrated SQLite DB and controlled
auth/health fixtures. Production must not accept a test-header login bypass.

Each code node runs the root AGENTS checks applicable to its changes. This
documentation node verifies formatting, links, and contract consistency; it
does not pretend app tests validate designs. Next-wave contracts remain
provisional until this review lands, then are prepared individually.
