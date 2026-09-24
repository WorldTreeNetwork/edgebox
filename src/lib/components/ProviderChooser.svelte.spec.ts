import { page, userEvent } from 'vitest/browser';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-svelte';
import ProviderChooser from './ProviderChooser.svelte';

const providers = [
	{ id: 'vikunja', name: 'Vikunja', summary: 'Shared tasks.', state: 'online' as const },
	{ id: 'stirling', name: 'Stirling PDF', summary: 'PDF work.', state: 'online' as const }
];

describe('ProviderChooser', () => {
	it('supports keyboard provider selection and emits only the selected identifier', async () => {
		const onOpenOnce = vi.fn();
		render(ProviderChooser, { providers, viewer: 'member', onOpenOnce });

		await userEvent.click(page.getByRole('button', { name: 'Choose another app' }));
		const firstProvider = page.getByRole('radio', { name: /Vikunja/ });
		await userEvent.click(firstProvider);
		await userEvent.keyboard('{ArrowDown}');
		await userEvent.click(page.getByRole('button', { name: 'Open once' }));

		expect(onOpenOnce).toHaveBeenCalledWith('stirling');
	});

	it('closes with Escape and returns focus to the trigger', async () => {
		render(ProviderChooser, { providers });
		const trigger = page.getByRole('button', { name: 'Choose another app' });
		await userEvent.click(trigger);
		const dialog = page.getByRole('dialog');
		await expect.element(dialog).toBeVisible();
		await userEvent.keyboard('{Escape}');
		await expect.element(dialog).not.toBeInTheDocument();
		await expect.element(trigger).toHaveFocus();
	});
});
