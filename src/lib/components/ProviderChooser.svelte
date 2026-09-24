<script lang="ts">
	import '#lib/styles/edgebox.css';
	import type { ApplicationSummary } from '../catalog';
	import ServiceStatus, { type ServiceState } from './ServiceStatus.svelte';

	export type ProviderOption = Pick<ApplicationSummary, 'id' | 'name' | 'summary'> & {
		state: ServiceState;
		disabled?: boolean;
		reason?: string;
	};
	let {
		providers,
		viewer = 'guest',
		pending = false,
		error = null,
		onOpenOnce,
		onSave,
		onSignIn
	}: {
		providers: ProviderOption[];
		viewer?: 'guest' | 'member' | 'operator';
		pending?: boolean;
		error?: string | null;
		onOpenOnce?: (id: string) => void;
		onSave?: (id: string) => void;
		onSignIn?: () => void;
	} = $props();
	let dialog: HTMLDialogElement;
	let selected = $derived(providers.find((provider) => !provider.disabled)?.id ?? '');
	function close() {
		dialog.close();
	}
	function openOnce() {
		if (selected) onOpenOnce?.(selected);
	}
	function save() {
		if (selected) onSave?.(selected);
	}
</script>

<div class="edgebox-kit">
	<button
		class="border-edge-line bg-edge-paper hover:bg-edge-paper-deep min-h-11 rounded-lg border px-4 font-sans text-sm font-bold"
		type="button"
		onclick={() => dialog.showModal()}>Choose another app</button
	>
	<dialog
		class="border-edge-line bg-edge-paper text-edge-ink backdrop:bg-edge-ink/30 m-auto w-[min(38rem,calc(100%-2rem))] rounded-xl border p-0 shadow-xl"
		bind:this={dialog}
		aria-labelledby="provider-chooser-title"
	>
		<form method="dialog" class="p-5" onsubmit={(event) => event.preventDefault()}>
			<div class="flex items-start justify-between gap-4">
				<div>
					<p class="text-edge-moss text-xs font-bold tracking-[.15em] uppercase">Choose an app</p>
					<h2 id="provider-chooser-title" class="mt-1 text-2xl font-bold tracking-tight">
						Open this action with
					</h2>
				</div>
				<button
					class="min-h-11 rounded-lg px-3 font-sans text-sm font-bold"
					type="button"
					onclick={close}>Cancel</button
				>
			</div>
			<fieldset class="mt-5 grid gap-2" disabled={pending}>
				<legend class="sr-only">Available applications</legend
				>{#each providers as provider (provider.id)}<label
						class={`flex cursor-pointer items-start gap-3 rounded-lg border p-4 ${selected === provider.id ? 'border-edge-moss bg-edge-moss/5' : 'border-edge-line'} ${provider.disabled ? 'cursor-not-allowed opacity-60' : ''}`}
						><input
							class="mt-1"
							type="radio"
							name="provider"
							value={provider.id}
							bind:group={selected}
							disabled={provider.disabled}
						/><span class="min-w-0 flex-1"
							><span class="block font-bold">{provider.name}</span><span
								class="text-edge-muted mt-1 block text-sm">{provider.summary}</span
							>{#if provider.reason}<span class="text-edge-clay mt-1 block text-sm font-semibold"
									>{provider.reason}</span
								>{/if}</span
						><ServiceStatus state={provider.state} /></label
					>{/each}
			</fieldset>
			{#if providers.length === 0}<p class="bg-edge-paper-deep text-edge-muted mt-5 rounded-lg p-4">
					No app is available for this action. Browse Applications to find another tool.
				</p>{/if}
			{#if error}<p
					class="border-edge-clay/30 bg-edge-clay/10 text-edge-clay mt-4 rounded-lg border p-3 text-sm font-semibold"
					role="alert"
				>
					{error}
				</p>{/if}
			<div class="mt-6 flex flex-wrap gap-2">
				<button
					class="bg-edge-ink text-edge-paper min-h-11 rounded-lg px-4 font-sans text-sm font-bold disabled:opacity-60"
					type="button"
					disabled={!selected || pending}
					onclick={openOnce}>{pending ? 'Working…' : 'Open once'}</button
				>{#if viewer === 'guest'}<button
						class="text-edge-moss min-h-11 rounded-lg px-4 font-sans text-sm font-bold underline underline-offset-4"
						type="button"
						onclick={onSignIn}>Sign in to save a preferred app</button
					>{:else}<button
						class="border-edge-line min-h-11 rounded-lg border px-4 font-sans text-sm font-bold disabled:opacity-60"
						type="button"
						disabled={!selected || pending}
						onclick={save}>Save as preferred</button
					>{/if}
			</div>
		</form>
	</dialog>
</div>
