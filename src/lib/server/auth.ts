import {
	ORIGIN,
	BETTER_AUTH_SECRET,
	IDENTIKEY_CLIENT_ID,
	IDENTIKEY_CLIENT_SECRET
} from '$app/env/private';

import { betterAuth } from 'better-auth/minimal';
import { drizzleAdapter } from 'better-auth/adapters/drizzle';
import { genericOAuth } from 'better-auth/plugins/generic-oauth';
import { sveltekitCookies } from 'better-auth/svelte-kit';
import { getRequestEvent } from '$app/server';
import { db } from '#lib/server/db/index.js';

const identikey = IDENTIKEY_CLIENT_ID
	? genericOAuth({
			config: [
				{
					providerId: 'identikey',
					name: 'Identikey',
					clientId: IDENTIKEY_CLIENT_ID,
					clientSecret: IDENTIKEY_CLIENT_SECRET,
					discoveryUrl: 'https://auth.identikey.me/.well-known/openid-configuration',
					requireIdTokenVerification: true,
					scopes: ['openid']
				}
			]
		})
	: undefined;

export const auth = betterAuth({
	baseURL: ORIGIN,
	secret: BETTER_AUTH_SECRET,
	database: drizzleAdapter(db, { provider: 'sqlite' }),
	emailAndPassword: { enabled: true },
	plugins: [
		...(identikey ? [identikey] : []),
		sveltekitCookies(getRequestEvent) // make sure this is the last plugin in the array
	]
});
