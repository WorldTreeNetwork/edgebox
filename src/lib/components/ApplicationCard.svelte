<script lang="ts">
	import '#lib/styles/edgebox.css';
	import type { ApplicationSummary } from '../catalog';
	import ServiceStatus from './ServiceStatus.svelte';

	let { application }: { application: ApplicationSummary } = $props();
</script>

<article
	class="edgebox-kit group border-edge-line bg-edge-paper hover:border-edge-moss/40 relative flex h-full flex-col rounded-xl border p-5 shadow-[0_1px_2px_rgba(36,48,43,.04)]"
>
	<p class="text-edge-moss text-xs font-bold tracking-[.15em] uppercase">Application</p>
	<h3 class="mt-2 text-xl font-bold tracking-tight">
		<a class="after:absolute after:inset-0" href={`/applications/${application.id}`}
			>{application.name}</a
		>
	</h3>
	<p class="text-edge-muted mt-2 leading-6 text-pretty">{application.summary}</p>
	<div class="relative mt-auto flex items-end justify-between gap-3 pt-5">
		<p class="text-edge-muted text-sm">
			{application.launchUrl ? 'Entry point configured' : 'Entry point not configured'}
		</p>
		<ServiceStatus
			state={application.health.state}
			checkedAt={application.health.checkedAt}
			setupNotice={application.setupNotice}
		/>
	</div>
</article>
