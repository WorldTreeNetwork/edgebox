import { page, userEvent } from 'vitest/browser';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-svelte';
import PasskeyRow from './PasskeyRow.svelte';

const credential = {
	id: 'kitchen-ipad',
	name: 'Kitchen iPad',
	createdAt: 'Sep 21, 2026',
	lastUsedAt: 'today'
};

describe('PasskeyRow', () => {
	it('keeps the rename dialog open with an associated inline validation error', async () => {
		render(PasskeyRow, { credential, onRename: vi.fn() });
		const trigger = page.getByRole('button', { name: 'Rename Kitchen iPad' });
		await userEvent.click(trigger);
		const dialog = page.getByRole('dialog', { name: 'Rename passkey' });
		const input = dialog.getByRole('textbox', { name: 'Name' });
		await userEvent.clear(input);
		await userEvent.click(dialog.getByRole('button', { name: 'Save name' }));
		await expect.element(dialog.getByRole('alert')).toHaveTextContent('Enter a passkey name.');
		await expect.element(input).toHaveAttribute('aria-describedby', 'passkey-name-error');
		await userEvent.click(dialog.getByRole('button', { name: 'Cancel' }));
		await expect.element(trigger).toHaveFocus();
	});

	it('prevents final-passkey removal without recovery and keeps a clear explanation', async () => {
		render(PasskeyRow, { credential, lastPasskey: true, hasRecovery: false });
		await userEvent.click(page.getByRole('button', { name: 'Remove Kitchen iPad' }));
		await expect.element(page.getByText(/cannot remove your final passkey/i)).toBeVisible();
		await expect.element(page.getByRole('button', { name: 'Remove passkey' })).toBeDisabled();
	});
});
