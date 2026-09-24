import { page, userEvent } from 'vitest/browser';
import { describe, expect, it, vi } from 'vitest';
import { render } from 'vitest-browser-svelte';
import HomeSearch from './HomeSearch.svelte';

describe('HomeSearch', () => {
	it('submits a trimmed capability query from the labeled field', async () => {
		const onSearch = vi.fn();
		render(HomeSearch, { onSearch });

		const input = page.getByLabelText('What would you like to do?');
		await userEvent.type(input, '  PDF  {Enter}');

		expect(onSearch).toHaveBeenCalledWith('/capabilities?q=PDF');
	});

	it('uses the unfiltered destination for blank searches', async () => {
		const onSearch = vi.fn();
		render(HomeSearch, { initialQuery: '   ', onSearch });

		await userEvent.click(page.getByRole('button', { name: 'Find an action' }));

		expect(onSearch).toHaveBeenCalledWith('/capabilities');
	});
});
