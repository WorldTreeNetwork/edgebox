<script lang="ts">
	import '#lib/styles/edgebox.css';

	export type PasskeyCredential = {
		id: string;
		name: string;
		createdAt: string;
		lastUsedAt: string | null;
	};
	let {
		credential,
		pending = false,
		error = null,
		lastPasskey = false,
		hasRecovery = true,
		onRename,
		onRemove
	}: {
		credential: PasskeyCredential;
		pending?: boolean;
		error?: string | null;
		lastPasskey?: boolean;
		hasRecovery?: boolean;
		onRename?: (id: string, name: string) => void;
		onRemove?: (id: string) => void;
	} = $props();
	let renameDialog: HTMLDialogElement;
	let removeDialog: HTMLDialogElement;
	let name = $derived(credential.name);
	let validation = $state('');
	let acknowledged = $state(false);
	function openRename() {
		name = credential.name;
		validation = '';
		renameDialog.showModal();
	}
	function saveRename() {
		const next = name.trim();
		if (!next) {
			validation = 'Enter a passkey name.';
			return;
		}
		onRename?.(credential.id, next);
	}
	function remove() {
		if (!lastPasskey || hasRecovery) onRemove?.(credential.id);
	}
</script>

<article
	class="edgebox-kit border-edge-line bg-edge-paper flex flex-wrap items-center justify-between gap-4 rounded-xl border p-4"
>
	<div>
		<h3 class="font-bold">{credential.name}</h3>
		<p class="text-edge-muted mt-1 text-sm">
			Created {credential.createdAt}{#if credential.lastUsedAt}
				· Last used {credential.lastUsedAt}{/if}
		</p>
	</div>
	<div class="flex gap-2">
		<button
			class="border-edge-line min-h-11 rounded-lg border px-3 font-sans text-sm font-bold"
			type="button"
			onclick={openRename}>Rename {credential.name}</button
		><button
			class="text-edge-clay hover:bg-edge-clay/10 min-h-11 rounded-lg px-3 font-sans text-sm font-bold"
			type="button"
			onclick={() => removeDialog.showModal()}>Remove {credential.name}</button
		>
	</div>
	{#if error}<p class="text-edge-clay basis-full text-sm font-semibold" role="alert">
			{error}
		</p>{/if}
	<dialog
		class="border-edge-line bg-edge-paper m-auto w-[min(28rem,calc(100%-2rem))] rounded-xl border p-0 shadow-xl"
		bind:this={renameDialog}
		aria-labelledby="rename-passkey-title"
	>
		<form
			class="p-5"
			onsubmit={(event) => {
				event.preventDefault();
				saveRename();
			}}
		>
			<h2 id="rename-passkey-title" class="text-xl font-bold">Rename passkey</h2>
			<label class="mt-4 grid gap-1 text-sm font-bold" for="passkey-name"
				>Name<input
					id="passkey-name"
					class="border-edge-line bg-edge-paper-deep min-h-11 rounded-lg px-3 font-sans font-normal"
					bind:value={name}
					aria-describedby={validation ? 'passkey-name-error' : undefined}
				/></label
			>{#if validation}<p
					id="passkey-name-error"
					class="text-edge-clay mt-2 text-sm font-semibold"
					role="alert"
				>
					{validation}
				</p>{/if}
			<div class="mt-5 flex gap-2">
				<button
					class="bg-edge-ink text-edge-paper min-h-11 rounded-lg px-4 font-sans text-sm font-bold disabled:opacity-60"
					disabled={pending}>Save name</button
				><button
					class="min-h-11 rounded-lg px-4 font-sans text-sm font-bold"
					type="button"
					onclick={() => renameDialog.close()}>Cancel</button
				>
			</div>
		</form>
	</dialog>
	<dialog
		class="border-edge-line bg-edge-paper m-auto w-[min(28rem,calc(100%-2rem))] rounded-xl border p-0 shadow-xl"
		bind:this={removeDialog}
		aria-labelledby="remove-passkey-title"
	>
		<form
			class="p-5"
			onsubmit={(event) => {
				event.preventDefault();
				remove();
			}}
		>
			<h2 id="remove-passkey-title" class="text-xl font-bold">Remove passkey?</h2>
			{#if lastPasskey && !hasRecovery}<p
					class="border-edge-clay/30 bg-edge-clay/10 text-edge-clay mt-3 rounded-lg border p-3 text-sm"
				>
					You cannot remove your final passkey until a verified Identikey recovery path is
					available.
				</p>{:else if lastPasskey}<label class="mt-4 flex gap-2 text-sm"
					><input type="checkbox" bind:checked={acknowledged} /> I understand I will sign in with Identikey
					next time.</label
				>{:else}<p class="text-edge-muted mt-3">
					This removes this local sign-in method. It does not affect other applications.
				</p>{/if}
			<div class="mt-5 flex gap-2">
				<button
					class="bg-edge-clay text-edge-paper min-h-11 rounded-lg px-4 font-sans text-sm font-bold disabled:opacity-60"
					disabled={pending || (lastPasskey && (!hasRecovery || !acknowledged))}
					>Remove passkey</button
				><button
					class="min-h-11 rounded-lg px-4 font-sans text-sm font-bold"
					type="button"
					onclick={() => removeDialog.close()}>Cancel</button
				>
			</div>
		</form>
	</dialog>
</article>
