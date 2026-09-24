<script lang="ts">
	import type { PageServerData } from './$types';
	import { AppShell, ApplicationDetail } from '#lib/components/index.js';

	let { data }: { data: PageServerData } = $props();
</script>

<svelte:head><title>{data.application.name} · Edgebox</title></svelte:head>

<AppShell viewer={data.viewer} currentPath="/applications" title={data.application.name}>
	<a
		class="text-edge-moss inline-flex min-h-11 items-center text-sm font-bold underline underline-offset-4"
		href="/applications">Back to Applications</a
	>
	<div class="mt-4">
		<ApplicationDetail
			name={data.application.name}
			summary={data.application.summary}
			launchUrl={data.application.launchUrl}
			state={data.application.health.state}
			checkedAt={data.application.health.checkedAt}
			setupNotice={data.application.setupNotice}
			capabilities={data.capabilities}
		/>
	</div>
</AppShell>
