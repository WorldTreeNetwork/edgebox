import { error, fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { directory } from '#lib/server/directory/index.js';

const returnPath = (capabilityId: string) => `/capabilities/${encodeURIComponent(capabilityId)}`;

export const load: PageServerLoad = async ({ params, locals }) => {
	const result = await directory.capability(params.capability, locals);
	if (!result) error(404, 'That action is not available.');
	return result;
};

export const actions: Actions = {
	savePreference: async ({ request, params, locals }) => {
		const formData = await request.formData();
		const applicationId = formData.get('applicationId')?.toString().trim() ?? '';
		if (!applicationId || applicationId.length > 120) {
			return fail(400, {
				message: 'Choose an available app.',
				saved: false,
				attemptedApplicationId: ''
			});
		}
		try {
			const result = await directory.savePreference(locals, params.capability, applicationId);
			if (result.kind === 'auth-required') {
				redirect(303, `/login?returnTo=${encodeURIComponent(returnPath(params.capability))}`);
			}
			return {
				message: 'Preferred app saved.',
				saved: true,
				attemptedApplicationId: applicationId
			};
		} catch {
			return fail(400, {
				message: 'That app is no longer eligible. Your preference was not changed.',
				saved: false,
				attemptedApplicationId: applicationId
			});
		}
	},

	resetPreference: async ({ params, locals }) => {
		try {
			const result = await directory.resetPreference(locals, params.capability);
			if (result.kind === 'auth-required') {
				redirect(303, `/login?returnTo=${encodeURIComponent(returnPath(params.capability))}`);
			}
			return { message: 'The catalog default will be used.', reset: true };
		} catch {
			return fail(500, {
				message: 'The preference could not be reset. Your choice is unchanged.',
				reset: false
			});
		}
	}
};
