import type { PageServerLoad } from './$types';
import { directory } from '#lib/server/directory/index.js';

export const load: PageServerLoad = ({ url, locals }) => directory.capabilities(url, locals);
