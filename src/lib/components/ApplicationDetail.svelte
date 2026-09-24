<script lang="ts">
	import '#lib/styles/edgebox.css';
	import ServiceStatus, { type ServiceState } from './ServiceStatus.svelte';

	let {
		name,
		summary,
		launchUrl = null,
		state = 'unknown',
		checkedAt = null,
		setupNotice = null,
		sshAddress = null,
		capabilities = [],
		onCopySsh
	}: {
		name: string;
		summary: string;
		launchUrl?: string | null;
		state?: ServiceState;
		checkedAt?: string | null;
		setupNotice?: string | null;
		sshAddress?: string | null;
		capabilities?: { id: string; label: string }[];
		onCopySsh?: (address: string) => void;
	} = $props();
</script>

<article
	class="edgebox-kit border-edge-line bg-edge-paper max-w-3xl rounded-xl border p-6 shadow-[0_1px_2px_rgba(36,48,43,.04)]"
>
	<div class="flex flex-wrap items-start justify-between gap-4">
		<div>
			<p class="text-edge-moss text-xs font-bold tracking-[.15em] uppercase">Application</p>
			<h2 class="mt-1 text-3xl font-bold tracking-tight">{name}</h2>
			<p class="text-edge-muted mt-3 max-w-2xl leading-7 text-pretty">{summary}</p>
		</div>
		<ServiceStatus {state} {checkedAt} {setupNotice} />
	</div>
	{#if setupNotice}<aside class="border-edge-clay/30 bg-edge-clay/10 mt-6 rounded-lg border p-4">
			<strong>Setup needed.</strong>
			{setupNotice}
		</aside>{/if}
	<div class="mt-6 flex flex-wrap gap-3">
		{#if launchUrl}<a
				class="bg-edge-ink text-edge-paper hover:bg-edge-moss inline-flex min-h-11 items-center rounded-lg px-4 font-sans text-sm font-bold"
				href={launchUrl}
				target="_blank"
				rel="noopener noreferrer"
				>Open {name} <span class="ml-1 text-xs font-normal">(opens in new tab)</span></a
			>{:else}<p class="bg-edge-paper-deep text-edge-muted rounded-lg px-4 py-3 text-sm">
				This app’s entry point is not configured yet.
			</p>{/if}
	</div>
	{#if sshAddress}<div class="border-edge-line mt-6 border-t pt-5">
			<p class="text-sm font-bold">SSH address</p>
			<div class="mt-2 flex flex-wrap items-center gap-2">
				<code class="bg-edge-paper-deep rounded px-2 py-1 font-sans text-sm select-all"
					>{sshAddress}</code
				><button
					class="border-edge-line min-h-11 rounded-lg border px-3 font-sans text-sm font-bold"
					type="button"
					onclick={() => onCopySsh?.(sshAddress!)}>Copy address</button
				>
			</div>
		</div>{/if}
	{#if capabilities.length}<div class="border-edge-line mt-6 border-t pt-5">
			<h3 class="font-bold">Things you can do with {name}</h3>
			<ul class="mt-3 grid gap-2">
				{#each capabilities as capability (capability.id)}<li>
						<a
							class="text-edge-moss inline-flex min-h-11 items-center font-sans text-sm font-bold underline underline-offset-4"
							href={`/capabilities/${capability.id}`}>{capability.label}</a
						>
					</li>{/each}
			</ul>
		</div>{/if}
</article>
