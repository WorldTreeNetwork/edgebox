# Edgebox

SvelteKit 3 application with Svelte 5, Tailwind CSS 4, Storybook, Drizzle ORM,
SQLite, Better Auth, Vitest, Playwright, and mdsvex.

Project direction and agent handoffs are documented in
[`ARCHITECTURE.md`](ARCHITECTURE.md), [`docs/ROADMAP.md`](docs/ROADMAP.md), and
[`docs/plans/`](docs/plans/). Delivered behavior lives in `openspec/specs/`.

## Get started

```sh
bun install
cp .env.example .env
bun run dev
```

`DATABASE_URL` defaults to `local.db`, so local development works when the
variable is omitted. In production, set it to a persistent writable path. The
remaining environment variables are documented in `.env.example`.

Identikey login uses OpenID Connect with PKCE and verified ID tokens. Register
`{ORIGIN}/api/auth/callback/identikey` as the client callback URL at
`auth.identikey.me`, then set `IDENTIKEY_CLIENT_ID`. Set
`IDENTIKEY_CLIENT_SECRET` only when the registered client is confidential.

## Everyday commands

```sh
bun run dev              # SvelteKit development server
bun run storybook        # component workshop on port 6006
bun run check            # Svelte and TypeScript checks
bun run lint             # Prettier and ESLint checks
bun run test             # unit, component, and story tests
bun run build            # production build, including migration files
bun run start            # run the Node production server
```

## Components and Storybook

Develop reusable UI in `src/lib` and keep its `*.stories.svelte` or
`*.stories.ts` file beside the component. Start from the closest shadcn-svelte
or other headless primitive, then adapt its markup and code to the product. Use
Storybook as the primary workspace for isolated states: normal, loading, empty,
error, disabled, and narrow-viewport states where applicable.

Storybook imports the app stylesheet, so Tailwind utilities, forms, and
typography render consistently. Run `bun run storybook` while developing and
`bun run build-storybook` to verify the static catalog.

## Styling

Tailwind CSS 4 is loaded from `src/routes/layout.css`. The official forms and
typography plugins are enabled there. Use ordinary utilities for layout and
component styling, `prose` for Markdown and long-form content, and explicit
utilities for product-specific form states and validation.

## Database workflow

SQLite uses Drizzle and `better-sqlite3`. Schema definitions live in
`src/lib/server/db/schema.ts`; generated SQL lives in `drizzle/` and is committed.

Always change the database with a migration:

1. Edit the schema files.
2. Run `bun run db:generate`.
3. Review the generated SQL in `drizzle/`.
4. Run the app or `bun run db:migrate` and test the change.
5. Commit the schema, SQL migration, and Drizzle metadata together.

Do not use schema push as the team workflow. Pending migrations are applied
idempotently when the server initializes the database, before it handles
requests. The production build copies `drizzle/` into the deployable build.

```sh
bun run db:generate      # generate SQL after changing schema
bun run db:migrate       # apply pending migrations manually
bun run db:studio        # inspect local data
```

For Better Auth changes, run `bun run auth:schema`, review its generated schema,
then generate and commit a Drizzle migration.

## Quality gate

Before opening a pull request, run:

```sh
bun run check
bun run lint
bun run test
bun run build-storybook
bun run build
```

Vitest has browser, server, and Storybook projects. Component tests run in
Chromium through Playwright; server tests run in Node. Prettier handles Svelte
and Tailwind ordering, and ESLint includes Svelte and Storybook rules.
