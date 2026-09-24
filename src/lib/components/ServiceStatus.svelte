<script lang="ts">
	import '#lib/styles/edgebox.css';
	import type { HealthState } from '../catalog';

	export type ServiceState = HealthState;

	let {
		state,
		checkedAt = null,
		setupNotice = null
	}: { state: ServiceState; checkedAt?: string | null; setupNotice?: string | null } = $props();

	const labels: Record<ServiceState, string> = {
		online: 'Available',
		unavailable: 'Unavailable',
		unknown: 'Not checked',
		stale: 'Check is old'
	};
</script>

<div
	class="edgebox-kit flex flex-wrap items-center gap-2 text-sm"
	aria-label={`Service status: ${labels[state]}`}
>
	<span
		class={`inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 font-semibold ${state === 'online' ? 'border-edge-moss/25 bg-edge-moss/10 text-edge-moss' : state === 'unavailable' ? 'border-edge-clay/25 bg-edge-clay/10 text-edge-clay' : 'border-edge-line bg-edge-paper-deep text-edge-slate'}`}
	>
		<span aria-hidden="true">{state === 'online' ? '●' : state === 'unavailable' ? '!' : '○'}</span>
		{labels[state]}
	</span>
	{#if checkedAt}<span class="text-edge-muted">Last checked {checkedAt}</span>{/if}
	{#if setupNotice}<span class="text-edge-clay font-medium">Setup needed: {setupNotice}</span>{/if}
</div>
