## ADDED Requirements

### Requirement: Curated catalog persistence

Edgebox SHALL persist applications, categories, capability/provider
associations, endpoints, and per-user provider preferences in SQLite through
committed Drizzle migrations, while preserving existing auth and task data.

#### Scenario: A fresh database starts

- GIVEN an empty SQLite database
- WHEN all committed migrations are applied
- THEN the curated catalog is present with stable identifiers
- AND a later migration run does not replace a member preference
- AND health is unknown until the health-observation capability records it.

### Requirement: Audience-safe catalog queries

Edgebox SHALL construct catalog DTOs only after applying the caller's explicit
viewer visibility and enabled-state rules.

#### Scenario: A guest reads the directory

- GIVEN public and operator-only catalog records
- WHEN a guest lists applications or capabilities
- THEN only enabled public applications and their visible associations appear
- AND no operator inventory is disclosed.

### Requirement: Deterministic provider resolution and ownership

Edgebox SHALL validate provider membership before storing a preference and
resolve an eligible saved preference before an eligible curated default, sole
provider fallback, or chooser.

#### Scenario: A user attempts a foreign association

- GIVEN a capability and a provider association belonging to another capability
- WHEN the user saves that association as a preference
- THEN the repository rejects it
- AND no preference is written.
