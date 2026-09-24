<script lang="ts">
	import '#lib/styles/edgebox.css';
	import type { CapabilitySummary } from '../catalog';
	import ServiceStatus, { type ServiceState } from './ServiceStatus.svelte';

	let {
		id,
		label,
		summary,
		provider = null,
		state = 'unknown'
	}: Pick<CapabilitySummary, 'id' | 'label' | 'summary'> & {
		provider?: string | null;
		state?: ServiceState;
	} = $props();
</script>

<article
	class="edgebox-kit group border-edge-line bg-edge-paper hover:border-edge-moss/40 flex h-full flex-col rounded-xl border p-5 shadow-[0_1px_2px_rgba(36,48,43,.04)]"
>
	<p class="text-edge-moss text-xs font-bold tracking-[.15em] uppercase">Action</p>
	<h3 class="mt-2 text-xl font-bold tracking-tight">
		<a class="after:absolute after:inset-0" href={`/capabilities/${id}`}>{label}</a>
	</h3>
	<p class="text-edge-muted mt-2 leading-6 text-pretty">{summary}</p>
	<div class="relative mt-auto flex items-end justify-between gap-3 pt-5">
		<p class="text-sm">
			<span class="text-edge-muted">Opens with</span> <strong>{provider ?? 'Choose an app'}</strong>
		</p>
		<ServiceStatus {state} />
	</div>
</article>
