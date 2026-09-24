# Journeys and interaction inventory

Each row is a product interaction contract for descendants. Story names below
are planned names, not claims of existing story files. UI work develops them
before routing integration, with data fixtures and callbacks independent of the
server. “Component” means a focused Vitest/browser or Storybook play test, not
two copies of the same test. E2E rows are grouped into four principal journeys
to keep coverage proportionate.

| ID / intent                  | App surface and successful path                                                              | Alternate / failure behavior                                                                                                                                                    | Storybook states                                                                                               | Minimal verification / owner                                                                                   |
| ---------------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| J01 Orient and navigate      | `/`; navigation to actions/apps; mobile menu and account menu                                | Empty catalog explains setup; guest sees Sign in; unauthorized System absent                                                                                                    | AppShell/Desktop, Mobile, Guest, Member, Operator; Home/Empty                                                  | Component: menu keyboard, close/focus return; interface kit                                                    |
| J02 Find an action           | `/capabilities`; search/category then open action detail                                     | No match exposes clear controls; unsupported category normalizes; filtered count announced                                                                                      | CapabilityDirectory/Populated, Filtered, NoResults                                                             | E2E discovery journey; server visibility/filter tests; directory                                               |
| J03 Browse apps              | `/applications`; type search, change category/availability, clear, reload/back               | No results retains controls; unavailable included by default; unknown status labeled                                                                                            | ApplicationDirectory/Default, Filtered, Empty, NoResults                                                       | Component filter callback/clear; E2E query persistence; directory                                              |
| J04 Inspect an app           | `/applications/[application]`; read capabilities, destination, status, SSH facts             | Unknown/private slug gives 404; unconfigured endpoint disables launch with explanation                                                                                          | ApplicationDetail/Available, Unknown, Unconfigured, NotFound                                                   | E2E discovery journey; server private-slug test; directory                                                     |
| J05 Open a capability        | `/capabilities/[capability]`; preferred/default/sole app resolves, explicit Open             | Many providers and no default require chooser; no providers has useful empty state                                                                                              | CapabilityDetail/Preferred, Default, Single, Choose, NoProvider                                                | Server resolution table; E2E preference/launch journey asserts approved new-tab URL; directory                 |
| J06 Choose once              | Capability detail → Choose another app → select → Open once                                  | Cancel/Escape preserves saved choice and restores focus; disabled provider has reason                                                                                           | ProviderChooser/Single, Multiple, NoSelection, NoEligibleProvider                                              | Component radio keyboard + cancel + open callback; interface kit                                               |
| J07 Save preference          | Chooser or `/settings/applications`; select then save                                        | Guest offered login; invalid/removed provider rejected; expired session returns to login; pending disables duplicate submit; error retains choice                               | ProviderChooser/Guest, Saving, Saved, SaveFailed, SessionExpired                                               | Server ownership and valid association; E2E preference/launch journey; catalog/directory                       |
| J08 Reset preference         | `/settings/applications` → Use default → remove only member override and run normal resolver | Eligible default wins; otherwise sole eligible provider, chooser for multiple, or no-provider for zero; unavailable resolved default shows recovery; failure retains preference | PreferredApps/ResetToDefault, ResetToSole, ResetToChooser, ResetToNone, ResetToUnavailableDefault, ResetFailed | Catalog server reset/resolver table covers all five outcomes and ownership; directory component reset feedback |
| J09 Recover from unavailable | Capability/app detail names unavailable preferred app, alternatives, last check              | Open alternative once or explicitly save it; try anyway doesn't clear preference; unknown/stale allowed with caveat; no alternative links directory                             | CapabilityDetail/UnavailablePreferred, NoAlternative, Stale, Unknown                                           | E2E recovery journey; server no-silent-reassignment test; health/directory                                     |
| J10 Handle setup-needed      | Vaultwarden detail → read HTTPS notice → Open setup                                          | Available status does not hide setup need; secrets/default passwords never displayed                                                                                            | ApplicationDetail/SetupNeeded                                                                                  | Component verifies notice and distinct action; directory                                                       |
| J11 Start Identikey login    | `/login?returnTo=...` → continue → provider → validated destination                          | Provider unconfigured/outage, rejected callback, canceled consent: safe error/retry and browse return; block foreign return URLs                                                | LoginPanel/IdentikeyReady, Unconfigured, Pending, Canceled, Error                                              | Auth server callback/return policy; controlled-boundary E2E sign-in; identity                                  |
| J12 Enroll passkey           | Signed-in, Identikey-linked member → `/settings/passkeys` → Add → browser prompt → name/save | Plain LAN HTTP/unsupported browser explains requirement; user cancellation benign; expired/fresh-auth requirement returns to login; failure retry without duplicate credential  | PasskeySettings/Empty, Supported, InsecureContext, Unsupported, Enrolling, Canceled, Error                     | E2E virtual-authenticator enroll flow; server identity/session test; identity                                  |
| J13 Use passkey              | `/login` → Use a passkey → browser prompt → same linked account/home                         | Unknown credential or failed assertion gives retry and Identikey alternative; cancel leaves login usable                                                                        | LoginPanel/PasskeyReady, PasskeyPending, PasskeyCanceled, PasskeyFailed                                        | E2E virtual-authenticator returning login; identity                                                            |
| J14 Rename passkey           | Row menu → rename dialog → validated nonempty bounded name → save                            | Empty name inline error; duplicate display name allowed with dates; save failure preserves input; cancel restores focus                                                         | PasskeyRow/Default, Renaming, InvalidName, DuplicateName, SaveFailed                                           | Component validation and keyboard dialog; server credential ownership; identity                                |
| J15 Remove passkey           | Row menu → confirm → recent auth → removal                                                   | Last credential requires verified Identikey fallback and explicit acknowledgment; otherwise prevented; failed removal retains row                                               | PasskeyRow/ConfirmRemove, LastWithRecovery, LastWithoutRecovery, RemoveFailed                                  | Server ownership/recovery guards; component confirm/cancel; identity                                           |
| J16 Account and sign out     | `/settings/account` shows linked identity; account menu Sign out → guest home                | Session expiry clears member data; failed sign-out offers retry; external-app sessions explained only where relevant                                                            | AccountMenu/Member, SigningOut, Error; AccountPanel/Linked                                                     | Auth server session invalidation; included sign-in E2E; identity                                               |
| J17 Operator observation     | `/system` → failures/list → bounded Refresh → timestamp updates                              | Nonoperator denied server-side; stale data remains during refresh; partial failure shown without erasing old observations; rate limit explains when retry is available          | SystemOverview/Healthy, Mixed, Refreshing, RefreshFailed, RateLimited                                          | Server authorization, URL policy, timeout/cache tests; component refresh state; health                         |
| J18 Copy SSH endpoint        | Forgejo detail → Copy SSH address → copied feedback                                          | Clipboard denied provides selectable text; never launches an SSH probe                                                                                                          | ApplicationDetail/SshEndpoint, CopyFailed                                                                      | Component clipboard success/fallback; directory                                                                |

### J19 — Home search

- Surface: `/`, a labeled GET search form submitting `q` to `/capabilities`.
- Scope: capability labels/summaries and associated visible app names/summaries;
  results remain capability cards. Hidden apps do not contribute search matches.
- Submit trims query text and preserves it in the results URL. Blank input opens
  `/capabilities` without `q`. Reload and browser back preserve the submitted
  search; no-results recovery reuses J02. Navigation to Applications is available
  for users looking specifically for app results.
- Storybook: `Home/SearchReady`, `Home/SearchEntered`, `Home/SearchBlank`;
  `CapabilityDirectory/NoResults` supplies the resulting empty state.
- Verification: interface-kit component test asserts labeled input, Enter submit,
  and correct query/destination callback; directory's existing discovery E2E
  begins with Home search and checks result URL/reload. Catalog server search
  tests prove text matching and hidden-association exclusion. No new E2E suite.

### J20 — Navigate from an app to capability preferences

- Surface: `/applications/[application]`, one individually labeled ordinary link
  per visible associated capability, targeting `/capabilities/[capability]`.
- Multiple capabilities require choosing one named link; none means no links.
  There are no inline provider/default controls, implicit app preselection, or
  preference writes on the app-detail page.
- Guest and member links behave identically. Destination uses J05–J07; a guest
  may browse or open once, and must sign in before saving a preferred app.
- Storybook: `ApplicationDetail/SingleCapability`, `MultipleCapabilities`,
  `NoCapabilities`, and `GuestCapabilityLinks`.
- Verification: directory component test checks correct per-capability hrefs and
  absent mutation controls; existing chooser/server tests own preference writes
  and authorization. Interface kit supplies these detail variants. No separate
  E2E flow is needed.

## Common interaction contracts

- Primary links and buttons have descriptive accessible names and visible focus.
  Open links indicate new-tab behavior. Status includes text, not just color.
- Dialog/Sheet owns focus, Escape, dismissal, and focus restoration via the chosen
  headless primitive. Confirmation has a clear cancel action. Pending writes do
  not allow duplicate submissions; failed writes retain user input.
- Inline input errors associate with their field. Completion/result-count changes
  announce politely; avoid announcing every keystroke. Busy states are bounded
  and recoverable. Motion respects reduced-motion preference.
- Mobile keeps the same content/actions and usable touch targets. Long names,
  endpoint text, absent avatar, and empty lists must fit without clipping or
  horizontal page overflow. Test one representative narrow viewport.
- Guest-to-member transitions preserve only validated local navigation context,
  never an unverified pending mutation. Saving a provider after login requires
  the user's explicit action on the restored page.

## Four integrated journeys

1. Discover: Home search → capability results → reload query → capability detail;
   then directory filtering → app detail → approved external link. Include a
   narrow viewport and no-results recovery.
2. Prefer and launch: controlled sign-in → select/save preferred provider →
   reload → open correct app → reset to default. Verify another user is unaffected
   in focused server tests rather than adding a second long browser flow.
3. Recover: unavailable preferred app → choose available alternative once →
   launch → original saved preference unchanged. Health backend is deterministic.
4. Identity: controlled Identikey boundary → enroll local passkey → sign out →
   passkey sign-in using a virtual authenticator. Component/server tests cover
   cancellation, bad assertion, unsupported contexts, rename, and removal guards.

Live Pi/OIDC uptime is not a prerequisite for CI. Test-only fixtures must be
isolated to test builds/processes and disposable databases, never deployed as
an authentication bypass. External link assertions do not submit forms to live
applications or store credentials on the Pi.
