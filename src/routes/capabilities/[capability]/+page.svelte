<script lang="ts">
	import { goto } from '$app/navigation';
	import type { ActionData, PageServerData } from './$types';
	import {
		AppShell,
		ApplicationDetail,
		EmptyState,
		ProviderChooser
	} from '#lib/components/index.js';

	let { data, form }: { data: PageServerData; form: ActionData } = $props();
	let saveForm: HTMLFormElement;
	let saveInput: HTMLInputElement;

	let resolved = $derived('provider' in data.resolution ? data.resolution.provider : null);
	let chooserProviders = $derived(
		data.capability.providers
			.map((provider) => ({
				id: provider.id,
				name: provider.name,
				summary: provider.summary,
				state: provider.health.state,
				disabled: !provider.launchUrl,
				reason: provider.launchUrl ? undefined : 'No approved entry point is configured.'
			}))
			.sort((a, b) =>
				a.id === form?.attemptedApplicationId ? -1 : b.id === form?.attemptedApplicationId ? 1 : 0
			)
	);

	function openOnce(applicationId: string) {
		const launchUrl = data.capability.providers.find(
			(provider) => provider.id === applicationId
		)?.launchUrl;
		if (!launchUrl) return;
		const opened = window.open(launchUrl, '_blank', 'noopener,noreferrer');
		if (opened) opened.opener = null;
	}

	function savePreference(applicationId: string) {
		saveInput.value = applicationId;
		saveForm.requestSubmit();
	}
</script>

<svelte:head><title>{data.capability.label} · Edgebox</title></svelte:head>

<AppShell viewer={data.viewer} currentPath="/capabilities" title={data.capability.label}>
	<a
		class="text-edge-moss inline-flex min-h-11 items-center text-sm font-bold underline underline-offset-4"
		href="/capabilities">Back to things you can do</a
	>
	<p class="text-edge-muted mt-3 max-w-2xl text-lg leading-7">{data.capability.summary}</p>

	{#if form?.message}
		<p
			class={`mt-5 rounded-lg border p-4 text-sm font-semibold ${form.saved || form.reset ? 'border-edge-moss/30 bg-edge-moss/10 text-edge-moss' : 'border-edge-clay/30 bg-edge-clay/10 text-edge-clay'}`}
			role="status"
		>
			{form.message}
		</p>
	{/if}

	{#if resolved}
		<div class="mt-8">
			<ApplicationDetail
				name={resolved.name}
				summary={resolved.summary}
				launchUrl={resolved.launchUrl}
				state={resolved.health.state}
				checkedAt={resolved.health.checkedAt}
				setupNotice={resolved.setupNotice}
			/>
		</div>
	{:else if data.resolution.kind === 'chooser'}
		<p class="border-edge-line bg-edge-paper mt-8 max-w-3xl rounded-xl border p-5">
			Several applications can help. Choose one to open it once or save it after signing in.
		</p>
	{:else}
		<div class="mt-8 max-w-3xl">
			<EmptyState
				title="No app is available for this action"
				message="The capability is known, but no approved application entry point is configured."
				actionLabel="Browse Applications"
				actionHref="/applications"
			/>
		</div>
	{/if}

	{#if chooserProviders.length}
		<div class="mt-5 flex flex-wrap items-center gap-3">
			<ProviderChooser
				providers={chooserProviders}
				viewer={data.viewer}
				error={form?.saved === false ? form.message : null}
				onOpenOnce={openOnce}
				onSave={savePreference}
				onSignIn={() =>
					goto(`/login?returnTo=${encodeURIComponent(`/capabilities/${data.capability.id}`)}`)}
			/>
			{#if data.capability.preferredProviderId}
				<form method="post" action="?/resetPreference">
					<button
						class="text-edge-moss min-h-11 rounded-lg px-4 text-sm font-bold underline underline-offset-4"
					>
						Use catalog default
					</button>
				</form>
			{/if}
		</div>
	{/if}

	<form class="hidden" method="post" action="?/savePreference" bind:this={saveForm}>
		<input name="applicationId" bind:this={saveInput} />
	</form>
</AppShell>
