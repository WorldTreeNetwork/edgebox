<script lang="ts">
	import { goto } from '$app/navigation';
	import type { PageServerData } from './$types';
	import { AppShell, CapabilityCard, DirectoryFilters, EmptyState } from '#lib/components/index.js';
	import { directoryUrl } from '../directory-url';

	let { data }: { data: PageServerData } = $props();

	function providerFor(item: PageServerData['capabilities'][number]) {
		return 'provider' in item.resolution ? item.resolution.provider : null;
	}
</script>

<svelte:head><title>Things you can do · Edgebox</title></svelte:head>

<AppShell viewer={data.viewer} currentPath="/capabilities" title="Things you can do">
	<p class="text-edge-muted max-w-2xl leading-7">
		Describe the job, then choose the app only when there is a useful choice to make.
	</p>
	<div class="mt-6">
		<DirectoryFilters
			categories={data.categories}
			initial={{
				query: data.filters.query,
				category: data.filters.category,
				availability: ''
			}}
			resultCount={data.capabilities.length}
			onChange={(values) => goto(directoryUrl('/capabilities', values))}
		/>
	</div>
	{#if data.capabilities.length}
		<div class="mt-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
			{#each data.capabilities as capability (capability.id)}
				{@const provider = providerFor(capability)}
				<div class="relative">
					<CapabilityCard
						id={capability.id}
						label={capability.label}
						summary={capability.summary}
						provider={provider?.name ?? null}
						state={provider?.health.state ?? 'unknown'}
					/>
				</div>
			{/each}
		</div>
	{:else}
		<div class="mt-6">
			<EmptyState
				title="No actions match these filters"
				message="Clear the filters or browse applications by name."
				actionLabel="Browse Applications"
				actionHref="/applications"
			/>
		</div>
	{/if}
</AppShell>
