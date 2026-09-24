import { defineEnvVars } from '@sveltejs/kit/env';

const optional = (value: string | undefined) => value || undefined;

export const variables = defineEnvVars({
	DATABASE_URL: {
		schema: (value) => value || 'local.db',
		description: 'SQLite database path. Defaults to `local.db`.'
	},
	ORIGIN: {
		schema: optional,
		description: 'The app origin (base URL), e.g. `http://localhost:5173`.'
	},
	BETTER_AUTH_SECRET: {
		schema: optional,
		description:
			'Secret used to sign tokens. For production use 32 characters generated with high entropy. See [Better Auth installation](https://www.better-auth.com/docs/installation).'
	},
	IDENTIKEY_CLIENT_ID: {
		schema: optional,
		description: 'OIDC client ID issued by auth.identikey.me.'
	},
	IDENTIKEY_CLIENT_SECRET: {
		schema: optional,
		description:
			'Optional OIDC client secret issued by auth.identikey.me. Leave empty for a public PKCE client.'
	}
});
