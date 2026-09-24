<script lang="ts">
	import '#lib/styles/edgebox.css';

	let {
		initialQuery = '',
		onSearch
	}: { initialQuery?: string; onSearch?: (destination: string) => void } = $props();
	let query = $derived(initialQuery);

	function submit(event: SubmitEvent) {
		event.preventDefault();
		const value = query.trim();
		onSearch?.(value ? `/capabilities?q=${encodeURIComponent(value)}` : '/capabilities');
	}
</script>

<form class="edgebox-kit max-w-2xl" action="/capabilities" method="get" onsubmit={submit}>
	<label class="mb-2 block text-sm font-bold" for="edgebox-home-search"
		>What would you like to do?</label
	>
	<div class="flex flex-col gap-2 sm:flex-row">
		<input
			id="edgebox-home-search"
			class="border-edge-line bg-edge-paper-deep text-edge-ink placeholder:text-edge-muted min-h-12 flex-1 rounded-lg px-4 font-sans text-base"
			name="q"
			bind:value={query}
			placeholder="Try “PDF”, “music”, or “tasks”"
		/>
		<button
			class="bg-edge-ink text-edge-paper hover:bg-edge-moss min-h-12 rounded-lg px-5 font-sans text-sm font-semibold"
			type="submit">Find an action</button
		>
	</div>
	<p class="text-edge-muted mt-2 text-sm">
		Searches things you can do, not private service details.
	</p>
</form>
