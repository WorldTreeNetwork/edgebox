<script lang="ts">
	import { goto } from '$app/navigation';
	import type { PageServerData } from './$types';
	import {
		AppShell,
		ApplicationCard,
		DirectoryFilters,
		EmptyState
	} from '#lib/components/index.js';
	import { directoryUrl } from '../directory-url';

	let { data }: { data: PageServerData } = $props();
</script>

<svelte:head><title>Applications · Edgebox</title></svelte:head>

<AppShell viewer={data.viewer} currentPath="/applications" title="Applications">
	<p class="text-edge-muted max-w-2xl leading-7">
		Browse the installed tools directly when you already know which app you want.
	</p>
	<div class="mt-6">
		<DirectoryFilters
			categories={data.categories}
			availability
			initial={{
				query: data.filters.query,
				category: data.filters.category,
				availability: data.filters.availability
			}}
			resultCount={data.applications.length}
			onChange={(values) => goto(directoryUrl('/applications', values, true))}
		/>
	</div>
	{#if data.applications.length}
		<div class="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
			{#each data.applications as application (application.id)}
				<ApplicationCard {application} />
			{/each}
		</div>
	{:else}
		<div class="mt-6">
			<EmptyState
				title="No applications match these filters"
				message="Clear the filters or find the action you want to complete."
				actionLabel="Browse things you can do"
				actionHref="/capabilities"
			/>
		</div>
	{/if}
</AppShell>
