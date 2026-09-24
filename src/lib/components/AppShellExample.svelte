<script lang="ts">
	import AppShell, { type Viewer } from './AppShell.svelte';
	let {
		viewer = 'guest',
		title = 'What would you like to do?'
	}: { viewer?: Viewer; title?: string } = $props();
</script>

<AppShell {viewer} {title}
	><p class="text-edge-muted">Curated household actions stay calm and easy to scan.</p></AppShell
>
