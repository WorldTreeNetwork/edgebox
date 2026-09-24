# Information architecture: Edgebox

The supplied product direction is the brief; no new interview is required for
this activated best-effort pass. Decisions are explicit so implementation can
proceed and later user feedback can change a concrete design.

## Site map

```text
/                                  Home
/capabilities                      Things you can do
/capabilities/[capability]          Capability details and provider choice
/applications                      Applications
/applications/[application]        Application details
/system                            Operator service overview
/settings                          Settings overview
/settings/applications             Preferred apps
/settings/passkeys                 Passkeys
/settings/account                  Account
/login                             Identikey / passkey sign-in
/api/auth/*                        Existing auth transport, not navigation
```

No new top-level Files page until personal storage exists. Demo routes are
retired from navigation by the identity/directory implementation nodes; existing
bookmarks may redirect to the nearest real surface without performing mutation.
Unknown slugs return a usable 404 with section navigation. Unauthorized private
application slugs also return 404 so existence is not disclosed.

## Navigation model

Primary navigation has Home, Things you can do, and Applications. Operators also
see System. Keep no more than two meaningful levels: index and detail. Settings
uses one secondary list for Preferred apps, Passkeys, and Account. An account
menu offers Settings and Sign out; guests see Sign in.

Desktop uses a compact persistent sidebar and readable content width. Mobile
uses a header with a labeled menu button opening a headless Sheet/Dialog;
navigation contents and ordering are identical, with focus returned on close.
Page titles remain outside the menu. Account actions remain reachable without
hover. Breadcrumb/back links appear on details and preserve the originating
directory query. No keyboard-command palette is required in this release.

## Content hierarchy

| Surface            | Priority, in order                                                                                                                                                                              |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Home               | “What would you like to do?”; direct search; curated common capabilities grouped by category; compact interruptions affecting those actions; links to full capability/application indexes       |
| Things you can do  | Page title; labeled search and category filters; result count; verb-labeled capability cards with current provider; no-result recovery                                                          |
| Capability detail  | Action and purpose; current/default provider with state; Open action; Choose another app; available alternatives; sign-in prompt for saving a preference                                        |
| Applications       | Title and purpose; search/category/availability filters; result count; consistent application cards; clear filters/no-results recovery                                                          |
| Application detail | Name, summary; state and last check; primary Open link or setup action; endpoint/SSH facts; individually labeled links to associated capability details, where provider preferences are managed |
| System             | Scope explanation; services needing attention; full infrastructure list and timestamp; bounded refresh action; diagnostic details without secret configuration                                  |
| Preferred apps     | Explanation; capabilities with saved/default provider; per-capability chooser and Use default/reset action; confirmation/error feedback                                                         |
| Passkeys           | Explanation of local sign-in; current credentials; Add passkey; item rename/remove controls; supported-context and last-passkey guidance                                                        |
| Account            | Display name and linked Identikey identity; sign-in method explanation; Sign out; no profile editing or destructive account deletion in this release                                            |
| Login              | Return purpose if present; Continue with Identikey; Use a passkey; provider unavailable and browser-support guidance; retry or return to browsing                                               |

Home is the expected 80% surface. Common capabilities are curated initially;
pins, recent activity, and usage-based ranking are deferred. Capability cards
show the current provider without making knowledge of its brand a prerequisite.

## User flows

1. Guest/returning member → Home → choose a capability → resolved provider and
   launch link. Multiple unresolved providers → chooser → open selected app.
2. Home search → capability results → capability detail → open resolved app;
   Applications search/filter → app results → application detail → open web UI.
   No results → clear filters, retaining query until the user removes it.
3. Capability detail → Choose another app → select provider → open once or,
   if signed in, save as preferred → confirmation → launch. Cancel leaves state
   unchanged. Signed-out saving → login → return to same capability and choose.
4. Preferred app unavailable → explanatory state → choose available alternative,
   retry check if permitted, or explicitly try existing link; changing a lasting
   preference is separate from temporary recovery.
5. Sign in → Identikey → return to validated local destination → optional passkey
   enrollment. Returning user → Use a passkey → browser prompt → same destination.
6. Settings → Passkeys → add/name, rename, or remove with contextual confirmation.
   Browser cancellation remains on the page and does not falsely report failure.
7. Operator → System → inspect stale/unavailable entries → bounded refresh →
   updated timestamp/result, or preserved previous result with refresh failure.

Every branch, including empty and failed states, is expanded in `journeys.md`.

Home's search submits to `/capabilities?q=...` and returns capability cards
matching the action text or associated visible app text. Blank search opens
`/capabilities`. Applications has its own search and app-card results. Submitted
queries survive reload/back; Home does not require live suggestions or a second
search overlay (J19).

Application details provide ordinary links for each associated capability, not
inline preference controls. Users choose the relevant capability first, then use
its existing chooser. Guest links behave identically; saving still requires
sign-in. No capability link silently preselects an app or writes a preference
(J20).

Use default in Preferred apps removes the member's override and resolves again:
eligible curated default → sole eligible provider → chooser when multiple →
no-provider state when none. A resolved but unavailable default shows recovery;
it does not silently fall through to a healthy app. Failed reset leaves the
previous selection intact (J08).

## Naming conventions

| Concept               | UI label                                                     | Meaning                                                        |
| --------------------- | ------------------------------------------------------------ | -------------------------------------------------------------- |
| Capability collection | Things you can do                                            | Actions people recognize without knowing products              |
| Capability item       | Verb phrase, e.g. “Manage tasks”                             | Stable underlying capability ID                                |
| Application           | App / Applications                                           | Installed user-facing software                                 |
| Provider              | Opens with / Preferred app                                   | App performing this action; avoid “provider” jargon in main UI |
| Category              | Documents, Files, Productivity, Personal, Development, Media | Navigation aid, not an executable action                       |
| Infrastructure        | System                                                       | Operator-only supporting services                              |
| Reachability          | Available, Unavailable, Not checked, Check is old            | Text accompanies icon/color                                    |
| Configuration caveat  | Setup needed                                                 | Independent from reachability                                  |
| Authentication        | Sign in with Identikey / Use a passkey                       | Edgebox identity; external apps may request their own sign-in  |

## Component reuse map

| Component / headless starting point                    | Shared surfaces                 | Behavior                                                                 |
| ------------------------------------------------------ | ------------------------------- | ------------------------------------------------------------------------ |
| AppShell / Sheet, navigation links, DropdownMenu       | All app routes                  | Same navigation and account actions, responsive layout                   |
| CapabilityCard / Card and native link                  | Home, capability index          | Action label, current provider, state, detail link                       |
| ApplicationCard / Card and native link                 | Directory, provider chooser     | Summary, capabilities, state; selection variant composed with RadioGroup |
| DirectoryFilters / Input, Select, Button               | Capabilities, applications      | Labeled filters, count announcement, explicit clear                      |
| ServiceStatus / Badge and time                         | Cards, details, System          | Non-color state, stale timestamp, setup notice separate                  |
| ProviderChooser / Dialog, RadioGroup, Checkbox, Button | Capability details, preferences | Keyboard selection, save versus open once, pending/error states          |
| ApplicationDetail / Card, Button/link, Alert           | Detail route, stories           | Approved destination, setup/unconfigured/offline variants                |
| EmptyState / text, Button/link                         | All collections                 | Context-specific next action                                             |
| AccountMenu / DropdownMenu                             | AppShell                        | Guest/member/operator variants                                           |
| LoginPanel / Button, Alert                             | Login                           | Identikey/passkey supported, unavailable, pending, canceled              |
| PasskeyRow / DropdownMenu, Dialog, Input, AlertDialog  | Passkey settings                | Name/date, rename/remove confirmation and failure                        |

Use compositional primitives; plain static content does not need artificial
interaction wrappers. Page components assemble these same building blocks.

## Content growth and URL strategy

Stable lowercase kebab slugs identify applications/capabilities/categories.
Renaming display text does not change identity or preferences. The first catalog
is small enough for server-side filtering without pagination. Add pagination
only with real growth; no speculative infinite-scroll infrastructure.

`/applications?q=pdf&category=documents&availability=available` and
`/capabilities?q=sign&category=documents` are shareable, reload-safe states.
Parameters are optional; unknown category/availability values normalize to the
unfiltered value, and search text is trimmed and bounded server-side. Search
matches names, summaries, and capability labels, case-insensitively. Search does
not reveal filtered-out private records. Clear filters resets facets; a separate
clear-search control removes the query. Use GET forms as the baseline and
progressive enhancement without changing semantics.

Capability detail is the stable shareable launch context. A link to an external
application is never encoded as an unvalidated return URL. Modal provider choice
does not require a separate URL, but its parent capability page does. Browser
back returns to the prior query and restores focus where practical. Settings
requires a session; System requires server-verified operator authorization.
