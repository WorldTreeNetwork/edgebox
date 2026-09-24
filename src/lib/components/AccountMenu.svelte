<script lang="ts">
	import '#lib/styles/edgebox.css';
	import type { Viewer } from './AppShell.svelte';

	let {
		viewer = 'guest',
		signOutState = 'idle',
		onSignOut
	}: {
		viewer?: Viewer;
		signOutState?: 'idle' | 'signing-out' | 'error';
		onSignOut?: () => void;
	} = $props();
</script>

<div class="edgebox-kit">
	{#if viewer === 'guest'}
		<a
			class="text-edge-moss inline-flex min-h-11 items-center font-sans text-sm font-bold underline underline-offset-4"
			href="/login">Sign in</a
		>
	{:else}
		<details class="relative">
			<summary
				class="border-edge-line bg-edge-paper hover:bg-edge-paper-deep flex min-h-11 cursor-pointer list-none items-center rounded-lg border px-3 font-sans text-sm font-bold"
				>Account <span aria-hidden="true" class="text-edge-muted ml-2">⌄</span></summary
			>
			<div
				class="border-edge-line bg-edge-paper absolute right-0 z-10 mt-2 grid min-w-44 gap-1 rounded-lg border p-2 shadow-lg"
			>
				<a
					class="hover:bg-edge-paper-deep min-h-11 rounded px-3 py-2 font-sans text-sm font-semibold"
					href="/settings">Settings</a
				><button
					class="hover:bg-edge-paper-deep min-h-11 rounded px-3 text-left font-sans text-sm font-semibold disabled:opacity-60"
					type="button"
					disabled={signOutState === 'signing-out'}
					onclick={onSignOut}>{signOutState === 'signing-out' ? 'Signing out…' : 'Sign out'}</button
				>{#if signOutState === 'error'}<p
						class="text-edge-clay px-3 pb-2 text-sm font-semibold"
						role="alert"
					>
						Sign out did not finish. Try again.
					</p>{/if}
			</div>
		</details>
	{/if}
</div>
