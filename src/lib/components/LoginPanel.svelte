<script lang="ts">
	import '#lib/styles/edgebox.css';

	export type LoginState = 'ready' | 'unconfigured' | 'pending' | 'canceled' | 'error';
	let {
		identikey = 'ready',
		passkey = 'ready',
		onIdentikey,
		onPasskey
	}: {
		identikey?: LoginState;
		passkey?: LoginState;
		onIdentikey?: () => void;
		onPasskey?: () => void;
	} = $props();
	const message = (state: LoginState, name: string) =>
		state === 'unconfigured'
			? `${name} is not available on this Edgebox yet.`
			: state === 'canceled'
				? `${name} was canceled. You can try again.`
				: state === 'error'
					? `${name} could not finish. Try again or use another sign-in method.`
					: null;
</script>

<section
	class="edgebox-kit border-edge-line bg-edge-paper max-w-md rounded-xl border p-6 shadow-[0_1px_2px_rgba(36,48,43,.04)]"
>
	<p class="text-edge-moss text-xs font-bold tracking-[.15em] uppercase">Sign in</p>
	<h2 class="mt-1 text-2xl font-bold tracking-tight">Welcome back to Edgebox</h2>
	<p class="text-edge-muted mt-3 leading-6 text-pretty">
		Your Edgebox account does not sign you into other local applications.
	</p>
	<div class="mt-6 grid gap-3">
		<button
			class="bg-edge-ink text-edge-paper min-h-11 rounded-lg px-4 font-sans text-sm font-bold disabled:opacity-60"
			type="button"
			disabled={identikey === 'pending' || identikey === 'unconfigured'}
			onclick={onIdentikey}
			>{identikey === 'pending' ? 'Connecting to Identikey…' : 'Continue with Identikey'}</button
		><button
			class="border-edge-line min-h-11 rounded-lg border px-4 font-sans text-sm font-bold disabled:opacity-60"
			type="button"
			disabled={passkey === 'pending' || passkey === 'unconfigured'}
			onclick={onPasskey}>{passkey === 'pending' ? 'Waiting for passkey…' : 'Use a passkey'}</button
		>
	</div>
	{#each [{ id: 'identikey', text: message(identikey, 'Identikey') }, { id: 'passkey', text: message(passkey, 'Passkey') }] as notice (notice.id)}{#if notice.text}<p
				class="border-edge-clay/30 bg-edge-clay/10 text-edge-clay mt-3 rounded-lg border p-3 text-sm font-semibold"
				role="alert"
			>
				{notice.text}
			</p>{/if}{/each}
</section>
