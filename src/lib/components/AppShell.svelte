<script lang="ts">
	import '#lib/styles/edgebox.css';
	import type { Viewer as CatalogViewer } from '../catalog';

	export type Viewer = CatalogViewer;
	let {
		viewer = 'guest',
		currentPath = '/',
		title,
		children
	}: {
		viewer?: Viewer;
		currentPath?: string;
		title: string;
		children?: import('svelte').Snippet;
	} = $props();
	let menu: HTMLDialogElement;
	const navigation = [
		{ href: '/', label: 'Home' },
		{ href: '/capabilities', label: 'Things you can do' },
		{ href: '/applications', label: 'Applications' }
	];
	function openMenu() {
		menu.showModal();
	}
	function closeMenu() {
		menu.close();
	}
</script>

<div class="edgebox-kit bg-edge-paper text-edge-ink min-h-screen">
	<aside class="border-edge-line bg-edge-paper fixed inset-y-0 hidden w-64 border-r p-5 md:block">
		<a class="font-sans text-lg font-black tracking-tight" href="/"
			>edgebox<span class="text-edge-moss">.</span></a
		>
		<nav class="mt-10 grid gap-1" aria-label="Primary navigation">
			{#each navigation as item (item.href)}<a
					class={`min-h-11 rounded-lg px-3 py-2 font-sans text-sm font-semibold ${currentPath === item.href ? 'bg-edge-paper-deep text-edge-ink' : 'text-edge-muted hover:bg-edge-paper-deep hover:text-edge-ink'}`}
					href={item.href}>{item.label}</a
				>{/each}
			{#if viewer === 'operator'}<a
					class={`min-h-11 rounded-lg px-3 py-2 font-sans text-sm font-semibold ${currentPath === '/system' ? 'bg-edge-paper-deep text-edge-ink' : 'text-edge-muted hover:bg-edge-paper-deep hover:text-edge-ink'}`}
					href="/system">System</a
				>{/if}
		</nav>
		<div class="border-edge-line absolute right-5 bottom-5 left-5 border-t pt-4">
			{#if viewer === 'guest'}<a
					class="text-edge-moss inline-flex min-h-11 items-center text-sm font-bold underline underline-offset-4"
					href="/login">Sign in</a
				>{:else}<a
					class="text-edge-moss inline-flex min-h-11 items-center text-sm font-bold underline underline-offset-4"
					href="/settings">Settings</a
				><button
					class="text-edge-slate ml-3 min-h-11 text-sm font-bold underline underline-offset-4"
					type="button">Sign out</button
				>{/if}
		</div>
	</aside>
	<header class="border-edge-line flex items-center justify-between border-b px-4 py-3 md:hidden">
		<a class="font-sans text-lg font-black tracking-tight" href="/"
			>edgebox<span class="text-edge-moss">.</span></a
		>
		<button
			class="border-edge-line min-h-11 rounded-lg border px-3 font-sans text-sm font-bold"
			type="button"
			onclick={openMenu}>Open navigation</button
		>
	</header>
	<dialog
		class="border-edge-line bg-edge-paper text-edge-ink backdrop:bg-edge-ink/30 m-auto w-[min(24rem,calc(100%-2rem))] rounded-xl border p-0 shadow-xl"
		bind:this={menu}
		aria-label="Navigation menu"
	>
		<div class="border-edge-line flex items-center justify-between border-b p-4">
			<strong class="font-sans">Navigation</strong><button
				class="min-h-11 rounded-lg px-3 font-sans text-sm font-bold"
				type="button"
				onclick={closeMenu}>Close navigation</button
			>
		</div>
		<nav class="grid gap-1 p-4" aria-label="Primary navigation">
			{#each navigation as item (item.href)}<a
					class="hover:bg-edge-paper-deep min-h-11 rounded-lg px-3 py-2 font-sans text-sm font-semibold"
					href={item.href}
					onclick={closeMenu}>{item.label}</a
				>{/each}{#if viewer === 'operator'}<a
					class="hover:bg-edge-paper-deep min-h-11 rounded-lg px-3 py-2 font-sans text-sm font-semibold"
					href="/system"
					onclick={closeMenu}>System</a
				>{/if}
		</nav>
		<div class="border-edge-line border-t p-4">
			{#if viewer === 'guest'}<a
					class="text-edge-moss inline-flex min-h-11 items-center font-sans text-sm font-bold underline underline-offset-4"
					href="/login">Sign in</a
				>{:else}<a
					class="text-edge-moss inline-flex min-h-11 items-center font-sans text-sm font-bold underline underline-offset-4"
					href="/settings">Settings</a
				>{/if}
		</div>
	</dialog>
	<main class="mx-auto max-w-6xl px-4 py-8 md:ml-64 md:px-10">
		<p class="text-edge-moss text-xs font-bold tracking-[.16em] uppercase">Edgebox</p>
		<h1 class="mt-1 text-3xl font-bold tracking-tight text-balance sm:text-4xl">{title}</h1>
		{#if children}<div class="mt-8">{@render children()}</div>{/if}
	</main>
</div>
