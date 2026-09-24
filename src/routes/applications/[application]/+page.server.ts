import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { directory } from '#lib/server/directory/index.js';

export const load: PageServerLoad = async ({ params, locals }) => {
	const result = await directory.application(params.application, locals);
	if (!result) error(404, 'That application is not available.');
	return result;
};
