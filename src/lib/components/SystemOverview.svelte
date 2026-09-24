<script lang="ts">
	import '#lib/styles/edgebox.css';
	import ServiceStatus, { type ServiceState } from './ServiceStatus.svelte';

	let {
		services,
		refreshedAt = null,
		refreshing = false,
		refreshError = null,
		retryAfter = null,
		onRefresh
	}: {
		services: {
			id: string;
			name: string;
			detail: string;
			state: ServiceState;
			checkedAt?: string | null;
		}[];
		refreshedAt?: string | null;
		refreshing?: boolean;
		refreshError?: string | null;
		retryAfter?: string | null;
		onRefresh?: () => void;
	} = $props();
</script>

<section class="edgebox-kit max-w-4xl">
	<div class="flex flex-wrap items-end justify-between gap-4">
		<div>
			<p class="text-edge-muted leading-6 text-pretty">
				Service reachability is a bounded observation, not a guarantee that an app is configured or
				ready.
			</p>
			{#if refreshedAt}<p class="text-edge-muted mt-2 text-sm">Last refreshed {refreshedAt}</p>{/if}
		</div>
		<button
			class="border-edge-line bg-edge-paper min-h-11 rounded-lg border px-4 font-sans text-sm font-bold disabled:opacity-60"
			type="button"
			disabled={refreshing || Boolean(retryAfter)}
			onclick={onRefresh}
			>{refreshing
				? 'Refreshing…'
				: retryAfter
					? `Try again ${retryAfter}`
					: 'Refresh status'}</button
		>
	</div>
	{#if refreshError}<p
			class="border-edge-clay/30 bg-edge-clay/10 text-edge-clay mt-4 rounded-lg border p-4 text-sm font-semibold"
			role="alert"
		>
			{refreshError}
		</p>{/if}
	<ul class="divide-edge-line border-edge-line bg-edge-paper mt-6 divide-y rounded-xl border">
		{#each services as service (service.id)}<li
				class="flex flex-wrap items-center justify-between gap-3 p-4"
			>
				<div>
					<h2 class="font-bold">{service.name}</h2>
					<p class="text-edge-muted mt-1 text-sm">{service.detail}</p>
				</div>
				<ServiceStatus state={service.state} checkedAt={service.checkedAt ?? null} />
			</li>{/each}
	</ul>
</section>
