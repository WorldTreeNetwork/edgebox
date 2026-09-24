<script lang="ts">
	import '#lib/styles/edgebox.css';

	export type PreferredApp = {
		capabilityId: string;
		capabilityLabel: string;
		applicationName: string | null;
		state: 'configured' | 'default' | 'reset-failed';
	};
	let {
		preferences,
		pending = false,
		onUseDefault
	}: {
		preferences: PreferredApp[];
		pending?: boolean;
		onUseDefault?: (capabilityId: string) => void;
	} = $props();
</script>

<section class="edgebox-kit max-w-3xl">
	<p class="text-edge-moss text-xs font-bold tracking-[.15em] uppercase">Preferred apps</p>
	<h2 class="mt-1 text-2xl font-bold tracking-tight">Choose defaults for your actions</h2>
	<p class="text-edge-muted mt-3">
		A preferred app is only used when it remains eligible. You can still open another app once.
	</p>
	<ul class="divide-edge-line border-edge-line bg-edge-paper mt-6 divide-y rounded-xl border">
		{#each preferences as preference (preference.capabilityId)}<li
				class="flex flex-wrap items-center justify-between gap-3 p-4"
			>
				<div>
					<h3 class="font-bold">{preference.capabilityLabel}</h3>
					<p class="text-edge-muted mt-1 text-sm">
						{preference.state === 'configured'
							? `Preferred app: ${preference.applicationName}`
							: preference.state === 'default'
								? `Using the catalog default: ${preference.applicationName ?? 'Choose an app'}`
								: 'We could not reset this preference. Your current choice is unchanged.'}
					</p>
				</div>
				<button
					class="border-edge-line min-h-11 rounded-lg border px-3 font-sans text-sm font-bold disabled:opacity-60"
					type="button"
					disabled={pending || preference.state === 'default'}
					onclick={() => onUseDefault?.(preference.capabilityId)}>Use default</button
				>
			</li>{/each}
	</ul>
</section>
