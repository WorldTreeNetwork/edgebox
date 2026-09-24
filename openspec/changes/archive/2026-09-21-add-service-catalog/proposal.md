# add-service-catalog

> **ACTIVE BUILD**

## Why

The accepted Edgebox home-base architecture needs one durable, typed source of
truth for the deliberately curated applications, capabilities, endpoints, and
per-member provider choices.

## What

- Add relational SQLite catalog tables without altering the starter task or
  Better Auth tables.
- Seed the dated, reviewed inventory with stable IDs through a generated
  Drizzle migration.
- Provide serializable catalog DTOs and a server repository for visibility,
  filters, provider resolution, and member-owned preferences.

## Preparation — 2026-09-21

- Dependency read: `add-edgebox-home-base` accepted design, IA, journeys, and
  scenario delta. Its catalog contract is the implementation source.
- Authority: activated `add-service-catalog` descendant in the user-requested
  run-wave. This change owns `src/lib/catalog`, catalog server code, schema,
  generated migration artifacts, and its own OpenSpec records.
- Existing state: SQLite/Drizzle startup migrations, Better Auth `user` rows,
  and the starter `task` table already exist. They remain intact.
- Shared boundary: catalog owns the canonical plain DTOs; interface work imports
  rather than redefines them. Health rows/probing, application routes, and UI
  remain separate descendants.
- Outcome: current preparation is sufficient. Seed health is represented as
  `unknown` in repository DTOs until the dedicated health-observation change
  introduces persisted observations.

## Out of scope

Health checks, Docker discovery, operator administration, application routes,
UI components, Pi configuration, SSO, credentials, and any destructive schema
retirement.
