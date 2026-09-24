## ADDED Requirements

### Requirement: Capability-first route composition

Edgebox SHALL compose its delivered catalog and interface components into a Home,
capability directory, application directory, and stable detail routes while
enforcing visibility before rendering DTO data.

#### Scenario: A guest searches from Home

- GIVEN the public Home search
- WHEN a guest submits a bounded query
- THEN the browser navigates to `/capabilities?q=...`
- AND results match visible capability or associated application text
- AND empty results retain filters and a clear recovery action.

#### Scenario: A guest inspects an application

- GIVEN a visible application with multiple associated capabilities
- WHEN the guest opens its detail route
- THEN every capability has an individually labeled link to its detail route
- AND no preference is changed or implied.

### Requirement: Transparent provider launch and member preferences

Edgebox SHALL resolve providers through the catalog repository, present only its
approved HTTP(S) launch URLs, and derive preference ownership from the server session.

#### Scenario: A member saves a preferred app

- GIVEN an authenticated member and an eligible provider association
- WHEN the member saves the provider for a capability
- THEN only that member's preference is stored
- AND subsequent resolution identifies the preferred provider.

#### Scenario: A guest attempts to save

- GIVEN no authenticated session
- WHEN persistent selection is requested
- THEN no preference is written
- AND the user is directed to login with a validated local return destination.

#### Scenario: A provider has no approved launch endpoint

- GIVEN a capability or application without an approved launch URL
- WHEN its detail route renders
- THEN no external launch is fabricated
- AND the page explains the unavailable entry point and offers directory navigation.
