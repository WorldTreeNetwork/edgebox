export const MAX_DIRECTORY_QUERY_LENGTH = 120;

export type DirectoryQuery = {
	query: string;
	category: string;
	availability: '' | 'available' | 'unavailable';
};

function bounded(value: string | null): string {
	return Array.from(value?.trim() ?? '')
		.slice(0, MAX_DIRECTORY_QUERY_LENGTH)
		.join('');
}

export function readDirectoryQuery(
	url: URL,
	categoryIds: ReadonlySet<string>,
	includeAvailability: boolean
): DirectoryQuery {
	const requestedCategory = bounded(url.searchParams.get('category'));
	const requestedAvailability = bounded(url.searchParams.get('availability'));

	return {
		query: bounded(url.searchParams.get('q')),
		category: categoryIds.has(requestedCategory) ? requestedCategory : '',
		availability:
			includeAvailability &&
			(requestedAvailability === 'available' || requestedAvailability === 'unavailable')
				? requestedAvailability
				: ''
	};
}

export function localReturnPath(value: string | null, fallback = '/'): string {
	if (!value || !value.startsWith('/') || value.startsWith('//')) return fallback;
	try {
		const parsed = new URL(value, 'http://edgebox.local');
		return parsed.origin === 'http://edgebox.local'
			? `${parsed.pathname}${parsed.search}${parsed.hash}`
			: fallback;
	} catch {
		return fallback;
	}
}
