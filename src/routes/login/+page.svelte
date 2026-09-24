<script lang="ts">
	import type { PageServerData } from './$types';
	import { AppShell } from '#lib/components/index.js';

	let { data }: { data: PageServerData } = $props();
</script>

<svelte:head><title>Sign in · Edgebox</title></svelte:head>

<AppShell viewer="guest" currentPath="/login" title="Sign in required">
	<section class="border-edge-line bg-edge-paper max-w-xl rounded-xl border p-6">
		<h2 class="text-xl font-bold">Saving preferences needs an Edgebox session</h2>
		<p class="text-edge-muted mt-3 leading-7">
			The production Identikey and passkey flow is not enabled by this change. You can use the
			existing demo sign-in while it is available, then return and save explicitly.
		</p>
		<div class="mt-5 flex flex-wrap gap-3">
			<a
				class="bg-edge-ink text-edge-paper inline-flex min-h-11 items-center rounded-lg px-4 text-sm font-bold"
				href="/demo/better-auth/login">Open demo sign-in</a
			>
			<a
				class="text-edge-moss inline-flex min-h-11 items-center px-3 text-sm font-bold underline underline-offset-4"
				href={data.returnTo}>Return to browsing</a
			>
		</div>
	</section>
</AppShell>
