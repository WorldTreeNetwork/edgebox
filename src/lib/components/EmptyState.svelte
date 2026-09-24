<script lang="ts">
	import '#lib/styles/edgebox.css';

	let {
		title,
		message,
		actionLabel,
		actionHref,
		onAction
	}: {
		title: string;
		message: string;
		actionLabel?: string;
		actionHref?: string;
		onAction?: () => void;
	} = $props();
</script>

<section
	class="edgebox-kit border-edge-line bg-edge-paper rounded-xl border px-6 py-10 text-center shadow-[0_1px_2px_rgba(36,48,43,.04)]"
>
	<p class="text-edge-moss text-xs font-bold tracking-[.18em] uppercase">Nothing here yet</p>
	<h2 class="mt-2 text-xl font-bold tracking-tight text-balance">{title}</h2>
	<p class="text-edge-muted mx-auto mt-2 max-w-md leading-6 text-pretty">{message}</p>
	{#if actionLabel && actionHref}
		<a
			class="bg-edge-ink text-edge-paper hover:bg-edge-moss mt-5 inline-flex min-h-11 items-center rounded-lg px-4 font-sans text-sm font-semibold"
			href={actionHref}>{actionLabel}</a
		>
	{:else if actionLabel}
		<button
			class="bg-edge-ink text-edge-paper hover:bg-edge-moss mt-5 min-h-11 rounded-lg px-4 font-sans text-sm font-semibold"
			onclick={onAction}>{actionLabel}</button
		>
	{/if}
</section>
