<script lang="ts">
	import { goto } from '$app/navigation';
	import type { PageServerData } from './$types';
	import { AppShell, CapabilityCard, EmptyState, HomeSearch } from '#lib/components/index.js';

	let { data }: { data: PageServerData } = $props();

	function providerFor(item: PageServerData['capabilities'][number]) {
		return 'provider' in item.resolution ? item.resolution.provider : null;
	}
</script>

<svelte:head><title>Home · Edgebox</title></svelte:head>

<AppShell viewer={data.viewer} currentPath="/" title="What would you like to do?">
	<p class="text-edge-muted max-w-2xl text-lg leading-7">
		Start with an action. Edgebox will show the installed app that can help.
	</p>
	<div class="mt-6"><HomeSearch onSearch={(destination) => goto(destination)} /></div>

	<section class="mt-12" aria-labelledby="common-actions-title">
		<div class="flex flex-wrap items-end justify-between gap-3">
			<div>
				<p class="text-edge-moss text-xs font-bold tracking-[.15em] uppercase">Common actions</p>
				<h2 id="common-actions-title" class="mt-1 text-2xl font-bold">Get something done</h2>
			</div>
			<a
				class="text-edge-moss min-h-11 py-3 text-sm font-bold underline underline-offset-4"
				href="/capabilities">See everything you can do</a
			>
		</div>
		{#if data.capabilities.length}
			<div class="mt-5 grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
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
			<div class="mt-5">
				<EmptyState
					title="Your action shelf is still empty"
					message="Browse the application directory to see what has been configured."
					actionLabel="Browse Applications"
					actionHref="/applications"
				/>
			</div>
		{/if}
	</section>
</AppShell>
