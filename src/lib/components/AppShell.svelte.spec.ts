import { page, userEvent } from 'vitest/browser';
import { describe, expect, it } from 'vitest';
import { render } from 'vitest-browser-svelte';
import AppShell from './AppShell.svelte';

describe('AppShell', () => {
	it('keeps guest navigation labeled and returns focus after Escape', async () => {
		render(AppShell, { viewer: 'guest', title: 'Welcome' });
		const trigger = page.getByRole('button', { name: 'Open navigation' });
		await userEvent.click(trigger);
		const menu = page.getByRole('dialog', { name: 'Navigation menu' });
		await expect.element(menu).toBeVisible();
		await expect.element(menu.getByRole('link', { name: 'Sign in' })).toBeVisible();
		await userEvent.keyboard('{Escape}');
		await expect.element(trigger).toHaveFocus();
	});
});
