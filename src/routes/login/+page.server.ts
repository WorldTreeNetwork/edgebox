import type { PageServerLoad } from './$types';
import { localReturnPath } from '#lib/server/directory/index.js';

export const load: PageServerLoad = ({ url }) => ({
	returnTo: localReturnPath(url.searchParams.get('returnTo'))
});
