<script lang="ts">
	import '#lib/styles/edgebox.css';
	import PasskeyRow, { type PasskeyCredential } from './PasskeyRow.svelte';

	let {
		credentials = [],
		availability = 'supported',
		onAdd,
		onRename,
		onRemove
	}: {
		credentials?: PasskeyCredential[];
		availability?: 'supported' | 'insecure' | 'unsupported';
		onAdd?: () => void;
		onRename?: (id: string, name: string) => void;
		onRemove?: (id: string) => void;
	} = $props();
</script>

<section class="edgebox-kit max-w-3xl">
	<div class="flex flex-wrap items-end justify-between gap-4">
		<div>
			<p class="text-edge-moss text-xs font-bold tracking-[.15em] uppercase">Passkeys</p>
			<h2 class="mt-1 text-2xl font-bold tracking-tight">Local sign-in methods</h2>
		</div>
		<button
			class="bg-edge-ink text-edge-paper min-h-11 rounded-lg px-4 font-sans text-sm font-bold disabled:opacity-60"
			type="button"
			disabled={availability !== 'supported'}
			onclick={onAdd}>Add a passkey</button
		>
	</div>
	{#if availability === 'insecure'}<p
			class="border-edge-clay/30 bg-edge-clay/10 text-edge-clay mt-4 rounded-lg border p-4 text-sm"
		>
			Passkeys need a secure HTTPS context on your local network.
		</p>{:else if availability === 'unsupported'}<p
			class="border-edge-clay/30 bg-edge-clay/10 text-edge-clay mt-4 rounded-lg border p-4 text-sm"
		>
			This browser does not support passkeys. Sign in with Identikey instead.
		</p>{/if}{#if credentials.length === 0}<p
			class="border-edge-line bg-edge-paper text-edge-muted mt-6 rounded-xl border p-6"
		>
			No passkeys yet. Add one for a quicker return to Edgebox.
		</p>{:else}<div class="mt-6 grid gap-3">
			{#each credentials as credential (credential.id)}<PasskeyRow
					{credential}
					lastPasskey={credentials.length === 1}
					{onRename}
					{onRemove}
				/>{/each}
		</div>{/if}
</section>
