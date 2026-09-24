<script lang="ts">
	import '#lib/styles/edgebox.css';

	export type FilterValues = { query: string; category: string; availability: string };
	let {
		categories = [],
		availability = false,
		initial = { query: '', category: '', availability: '' },
		resultCount = 0,
		onChange
	}: {
		categories?: { id: string; label: string }[];
		availability?: boolean;
		initial?: FilterValues;
		resultCount?: number;
		onChange?: (values: FilterValues) => void;
	} = $props();
	let values = $derived<FilterValues>({ ...initial });
	function apply(event: SubmitEvent) {
		event.preventDefault();
		onChange?.(values);
	}
	function clear() {
		values = { query: '', category: '', availability: '' };
		onChange?.(values);
	}
</script>

<form class="edgebox-kit border-edge-line bg-edge-paper rounded-xl border p-4" onsubmit={apply}>
	<div class="grid gap-3 md:grid-cols-[1fr_12rem_10rem_auto]">
		<label class="grid gap-1 text-sm font-semibold"
			>Search <input
				class="border-edge-line bg-edge-paper-deep min-h-11 rounded-lg px-3 font-sans font-normal"
				bind:value={values.query}
			/></label
		>
		<label class="grid gap-1 text-sm font-semibold"
			>Category <select
				class="border-edge-line bg-edge-paper-deep min-h-11 rounded-lg px-3 font-sans font-normal"
				bind:value={values.category}
				><option value="">All categories</option>{#each categories as category (category.id)}<option
						value={category.id}>{category.label}</option
					>{/each}</select
			></label
		>
		{#if availability}<label class="grid gap-1 text-sm font-semibold"
				>Availability <select
					class="border-edge-line bg-edge-paper-deep min-h-11 rounded-lg px-3 font-sans font-normal"
					bind:value={values.availability}
					><option value="">Any status</option><option value="available">Available</option><option
						value="unavailable">Unavailable</option
					></select
				></label
			>{/if}
		<div class="flex items-end gap-2">
			<button
				class="bg-edge-ink text-edge-paper hover:bg-edge-moss min-h-11 rounded-lg px-4 font-sans text-sm font-semibold"
				type="submit">Apply</button
			><button
				class="text-edge-slate hover:bg-edge-paper-deep min-h-11 rounded-lg px-3 font-sans text-sm font-semibold"
				type="button"
				onclick={clear}>Clear</button
			>
		</div>
	</div>
	<p class="text-edge-muted mt-3 text-sm" aria-live="polite">
		{resultCount}
		{resultCount === 1 ? 'result' : 'results'}
	</p>
</form>
