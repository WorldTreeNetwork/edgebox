import type { FilterValues } from '#lib/components/DirectoryFilters.svelte';

export function directoryUrl(
	pathname: '/capabilities' | '/applications',
	values: FilterValues,
	includeAvailability = false
): string {
	const parameters = new URLSearchParams();
	const query = values.query.trim();
	if (query) parameters.set('q', query);
	if (values.category) parameters.set('category', values.category);
	if (includeAvailability && values.availability) {
		parameters.set('availability', values.availability);
	}
	const search = parameters.toString();
	return search ? `${pathname}?${search}` : pathname;
}
