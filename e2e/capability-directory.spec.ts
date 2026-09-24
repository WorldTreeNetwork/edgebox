import { expect, test } from '@playwright/test';

test('discovers an action and follows its approved application details', async ({ page }) => {
	await page.goto('/');
	await expect(page.getByRole('heading', { name: 'What would you like to do?' })).toBeVisible();

	await page.getByLabel('What would you like to do?').fill('PDF');
	await page.getByRole('button', { name: 'Find an action' }).click();
	await expect(page).toHaveURL(/\/capabilities\?q=PDF$/);
	await expect(page.getByRole('link', { name: 'Work with PDFs' })).toBeVisible();

	await page.reload();
	await expect(page.getByLabel('Search')).toHaveValue('PDF');
	await page.getByRole('link', { name: 'Work with PDFs' }).click();
	await expect(page.getByRole('heading', { name: 'Work with PDFs', level: 1 })).toBeVisible();
	const openStirling = page.getByRole('link', { name: /Open Stirling PDF/ });
	await expect(openStirling).toHaveAttribute('href', 'http://192.168.0.90:8082/');
	await expect(openStirling).toHaveAttribute('target', '_blank');

	await page.getByRole('link', { name: 'Applications', exact: true }).first().click();
	await page.getByLabel('Search').fill('Vikunja');
	await page.getByRole('button', { name: 'Apply' }).click();
	await expect(page).toHaveURL(/\/applications\?q=Vikunja$/);
	await page.getByRole('link', { name: 'Vikunja' }).click();
	await expect(page.getByRole('link', { name: 'Manage tasks' })).toHaveAttribute(
		'href',
		'/capabilities/manage-tasks'
	);
});
