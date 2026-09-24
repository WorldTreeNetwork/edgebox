## ADDED Requirements

### Requirement: Capability-first navigation with an application directory

Edgebox SHALL provide a home organized around user intentions, a capability
index, an application directory, and detail surfaces with stable shareable URLs.

#### Scenario: A user knows the task but not the app

- GIVEN an eligible application implements a capability
- WHEN a user chooses that capability
- THEN the interface identifies its resolved provider and approved launch link
- AND provides an explicit way to choose an alternative.

#### Scenario: A user filters the directory

- GIVEN a curated visible catalog
- WHEN the user searches or selects category/availability filters
- THEN the URL preserves the query on reload and back navigation
- AND zero results retain controls and offer a clear recovery action.

#### Scenario: A user searches from Home

- GIVEN the Home search form
- WHEN the user submits a query
- THEN `/capabilities?q=...` presents capability results matching visible action
  or associated application text and preserves the query on reload/back
- AND a blank query opens the unfiltered capability index.

#### Scenario: An application supplies several capabilities

- GIVEN an application detail page with visible associated capabilities
- WHEN a user follows one individually labeled capability link
- THEN the corresponding capability detail owns provider choice and preference
  management, with sign-in required for a persistent preference
- AND following the link neither preselects the originating app nor mutates state.

### Requirement: Separate installation, capability, endpoint, and health data

Edgebox SHALL model applications, capability associations, categories, endpoints,
and current health separately, and SHALL persist schema changes through reviewed
Drizzle migrations applied before serving application requests.

#### Scenario: A fresh installation starts

- GIVEN a new SQLite database and committed migrations
- WHEN Edgebox initializes
- THEN pending migrations create the schema and curated inventory
- AND repeated startup preserves preferences and existing records
- AND service health remains unknown until observed.

#### Scenario: An application lacks a verified launch endpoint

- GIVEN an inventory record with an unknown endpoint
- WHEN the application is presented
- THEN no fabricated launch URL is offered
- AND the UI explains that its entry point is not configured.

### Requirement: Deterministic and user-owned provider preferences

Edgebox SHALL resolve eligible providers using the member preference, curated
default, sole-provider fallback, and explicit chooser in that order. Preference
mutations SHALL derive the owner from the server session and validate the
capability/provider association.

#### Scenario: A preferred application is unavailable

- GIVEN a saved preference whose application is currently unavailable
- WHEN the member opens the capability
- THEN the interface explains the condition and offers explicit recovery choices
- AND does not silently replace the saved preference.

#### Scenario: A guest wants to save a preference

- GIVEN no authenticated session
- WHEN a user requests persistent provider selection
- THEN sign-in is required
- AND no preference mutation occurs until authorized after sign-in.

#### Scenario: A member resets a preference

- GIVEN a saved capability preference
- WHEN the member selects Use default
- THEN only that member's saved override is removed
- AND resolution chooses the eligible curated default, otherwise the sole eligible
  provider, otherwise a chooser for multiple providers or the no-provider state
  for zero providers
- AND an unavailable resolved default retains explicit recovery choices rather
  than silently switching to another app
- AND a failed reset preserves the saved preference.

### Requirement: Authorized catalog views and transparent launches

Edgebox SHALL filter catalog data on the server by explicit visibility rules.
Operator views SHALL require explicit operator authorization. Launches SHALL use
approved catalog HTTP(S) endpoints and SHALL not imply application SSO or
transfer user data, tokens, or files.

#### Scenario: A nonoperator requests infrastructure data

- GIVEN infrastructure is marked operator-only
- WHEN a guest or ordinary member requests its route or data
- THEN the server withholds the protected records independent of UI visibility.

#### Scenario: An application is reachable but needs setup

- GIVEN Vaultwarden responds over its initial HTTP endpoint
- WHEN its details are displayed
- THEN trusted-HTTPS setup guidance remains visible
- AND reachability is not presented as readiness for storing real credentials.

### Requirement: Honest bounded health observations

Edgebox SHALL distinguish unknown, available, unavailable, and stale reachability
with observation times. Checks SHALL be limited to approved endpoints and bounded
in time, concurrency, and repetition, without blocking directory rendering.

#### Scenario: A check fails or becomes stale

- GIVEN a previously recorded observation
- WHEN a refresh fails or the observation ages beyond policy
- THEN the page remains usable and clearly reports the failed/stale observation
- AND does not overwrite it with fabricated success.

### Requirement: Identikey identity with optional local passkeys

Edgebox SHALL establish identities through verified Identikey authentication
and support enrolling local passkeys on the same account. Enrollment and
credential management SHALL require authenticated account ownership and the
appropriate secure browser context.

#### Scenario: A member enrolls on plain LAN HTTP

- GIVEN the browser lacks a secure WebAuthn context
- WHEN the member visits passkey settings
- THEN enrollment is unavailable with an explanation
- AND the existing Identikey sign-in path remains discoverable.

#### Scenario: A member removes the final passkey

- GIVEN the member owns the final local passkey
- WHEN removal is requested
- THEN recent authentication, confirmation, and a verified Identikey fallback
  with explicit acknowledgment are required
- AND absent that fallback the removal is prevented.

### Requirement: Shared accessible components with focused proof

Reusable interactions SHALL be developed in Storybook using the closest
shadcn-svelte or comparable headless primitive and shared app styling. The
application SHALL use those same components. Verification SHALL cover meaningful
interaction and authorization boundaries with focused component/server tests
and a small integrated end-to-end suite.

#### Scenario: Provider choice is integrated into the app

- GIVEN chooser stories cover keyboard, cancel, pending, saved, and failed states
- WHEN the capability route adopts the chooser
- THEN it renders the same component and preserves its focus/keyboard contracts
- AND focused tests prove selection, persistence ownership, and correct launch.
