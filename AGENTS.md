# Edgebox development instructions

## Components

- Use Storybook as the primary environment for developing reusable UI. Add or
  update stories alongside component work and cover meaningful states and
  interactions.
- Start every custom interactive component from the closest shadcn-svelte
  component or comparable headless primitive. Choose the closest match by
  behavior and accessibility, even when the final visual design is custom.
- Adapt the starting component's markup, styles, and code as needed. Preserve
  keyboard behavior, focus management, ARIA semantics, and other accessible
  interaction contracts unless the product behavior explicitly requires a
  well-tested change.
- If no exact component exists, compose the nearest primitives before building
  interaction behavior from scratch.

## Styling

- Use Tailwind CSS utilities and the shared app stylesheet. The forms and
  typography plugins are available; use `prose` for long-form content.
- Keep Storybook and application rendering aligned by relying on the same
  global stylesheet and tokens.

## Database

- Every SQLite schema change must have a reviewed, committed Drizzle migration.
  Do not use schema push as the normal development or deployment workflow.
- Run `bun run db:generate` after editing schema definitions and commit the SQL
  migration plus Drizzle metadata with the schema change.
- The application applies pending migrations at startup. Keep the `drizzle/`
  directory in development and production artifacts.

## Verification

- Run `bun run check`, `bun run lint`, and relevant tests after code changes.
- For UI changes, also run `bun run build-storybook`; for application or
  database changes, run `bun run build`.
