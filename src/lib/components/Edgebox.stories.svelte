<script module lang="ts">
	import { defineMeta } from '@storybook/addon-svelte-csf';
	import { fn } from 'storybook/test';
	import AppShellExample from './AppShellExample.svelte';
	import AccountMenu from './AccountMenu.svelte';
	import ApplicationCard from './ApplicationCard.svelte';
	import ApplicationDetail from './ApplicationDetail.svelte';
	import CapabilityCard from './CapabilityCard.svelte';
	import DirectoryFilters from './DirectoryFilters.svelte';
	import EmptyState from './EmptyState.svelte';
	import HomeSearch from './HomeSearch.svelte';
	import LoginPanel from './LoginPanel.svelte';
	import PasskeyRow from './PasskeyRow.svelte';
	import PasskeySettings from './PasskeySettings.svelte';
	import PreferredApps from './PreferredApps.svelte';
	import ProviderChooser from './ProviderChooser.svelte';
	import SystemOverview from './SystemOverview.svelte';

	const providers = [
		{
			id: 'vikunja',
			name: 'Vikunja',
			summary: 'Shared task lists for the household.',
			state: 'online' as const
		},
		{
			id: 'forgejo',
			name: 'Forgejo',
			summary: 'Code and issue tracking.',
			state: 'unavailable' as const,
			disabled: true,
			reason: 'This service is unavailable right now.'
		}
	];
	const categories = [
		{ id: 'productivity', label: 'Productivity' },
		{ id: 'documents', label: 'Documents' }
	];
	const application = {
		id: 'vikunja',
		name: 'Vikunja',
		summary: 'Shared task lists for the household.',
		categoryIds: ['productivity'],
		capabilityIds: ['manage-tasks'],
		launchUrl: 'https://vikunja.example.test',
		health: { state: 'online' as const, checkedAt: 'a moment ago' },
		setupNotice: null
	};
	const passkey = {
		id: 'kitchen-ipad',
		name: 'Kitchen iPad',
		createdAt: 'Sep 21, 2026',
		lastUsedAt: 'today'
	};
	const actions = {
		onSearch: fn(),
		onChange: fn(),
		onOpenOnce: fn(),
		onSave: fn(),
		onSignIn: fn(),
		onCopySsh: fn(),
		onRefresh: fn(),
		onSignOut: fn(),
		onIdentikey: fn(),
		onPasskey: fn(),
		onAdd: fn(),
		onRename: fn(),
		onRemove: fn(),
		onUseDefault: fn()
	};
	const { Story: HomeStory } = defineMeta({
		title: 'Home/Search',
		component: HomeSearch,
		args: { onSearch: actions.onSearch }
	});
	const { Story: ShellStory } = defineMeta({
		title: 'AppShell',
		component: AppShellExample,
		parameters: { layout: 'fullscreen' }
	});
	const { Story: CapabilityStory } = defineMeta({
		title: 'CapabilityCard',
		component: CapabilityCard
	});
	const { Story: ApplicationCardStory } = defineMeta({
		title: 'ApplicationCard',
		component: ApplicationCard,
		args: { application }
	});
	const { Story: AccountStory } = defineMeta({
		title: 'AccountMenu',
		component: AccountMenu,
		args: { onSignOut: actions.onSignOut }
	});
	const { Story: LoginStory } = defineMeta({
		title: 'LoginPanel',
		component: LoginPanel,
		args: { onIdentikey: actions.onIdentikey, onPasskey: actions.onPasskey }
	});
	const { Story: PasskeySettingsStory } = defineMeta({
		title: 'PasskeySettings',
		component: PasskeySettings,
		args: { onAdd: actions.onAdd, onRename: actions.onRename, onRemove: actions.onRemove }
	});
	const { Story: PasskeyRowStory } = defineMeta({
		title: 'PasskeyRow',
		component: PasskeyRow,
		args: { credential: passkey, onRename: actions.onRename, onRemove: actions.onRemove }
	});
	const { Story: PreferredAppsStory } = defineMeta({
		title: 'PreferredApps',
		component: PreferredApps,
		args: { onUseDefault: actions.onUseDefault }
	});
	const { Story: FiltersStory } = defineMeta({
		title: 'DirectoryFilters',
		component: DirectoryFilters,
		args: { categories, availability: true, resultCount: 4, onChange: actions.onChange }
	});
	const { Story: ChooserStory } = defineMeta({
		title: 'ProviderChooser',
		component: ProviderChooser,
		args: {
			providers,
			onOpenOnce: actions.onOpenOnce,
			onSave: actions.onSave,
			onSignIn: actions.onSignIn
		}
	});
	const { Story: DetailStory } = defineMeta({
		title: 'ApplicationDetail',
		component: ApplicationDetail,
		args: {
			name: 'Forgejo',
			summary: 'A private place for code and projects.',
			state: 'online',
			onCopySsh: actions.onCopySsh
		}
	});
	const { Story: SystemStory } = defineMeta({
		title: 'SystemOverview',
		component: SystemOverview,
		args: {
			services: [
				{ id: 'caddy', name: 'Caddy', detail: 'Routes local applications.', state: 'online' },
				{ id: 'gluetun', name: 'Gluetun', detail: 'Needs attention.', state: 'unavailable' }
			],
			onRefresh: actions.onRefresh
		}
	});
	const { Story: EmptyStory } = defineMeta({ title: 'EmptyState', component: EmptyState });
</script>

<HomeStory name="SearchReady" />
<HomeStory name="SearchEntered" args={{ initialQuery: 'PDF' }} />
<HomeStory name="SearchBlank" args={{ initialQuery: '   ' }} />

<ShellStory name="Desktop" args={{ viewer: 'member', title: 'What would you like to do?' }} />
<ShellStory name="Guest" args={{ viewer: 'guest', title: 'Welcome to Edgebox' }} />
<ShellStory name="Operator" args={{ viewer: 'operator', title: 'System' }} />
<ShellStory
	name="Mobile"
	args={{ viewer: 'guest', title: 'Things you can do' }}
	parameters={{ viewport: { defaultViewport: 'mobile1' } }}
/>

<CapabilityStory
	name="Available"
	args={{
		id: 'manage-tasks',
		label: 'Manage tasks',
		summary: 'Keep shared plans moving.',
		provider: 'Vikunja',
		state: 'online'
	}}
/>

<ApplicationCardStory name="Available" />
<ApplicationCardStory
	name="Unavailable"
	args={{
		application: { ...application, health: { state: 'unavailable', checkedAt: '10 minutes ago' } }
	}}
/>
<ApplicationCardStory
	name="Unknown"
	args={{
		application: {
			...application,
			name: 'Jellyfin',
			launchUrl: null,
			health: { state: 'unknown', checkedAt: null }
		}
	}}
/>

<AccountStory name="Guest" args={{ viewer: 'guest' }} />
<AccountStory name="Member" args={{ viewer: 'member' }} />
<AccountStory name="Operator" args={{ viewer: 'operator' }} />
<AccountStory name="SigningOut" args={{ viewer: 'member', signOutState: 'signing-out' }} />
<AccountStory name="Error" args={{ viewer: 'member', signOutState: 'error' }} />

<LoginStory name="IdentikeyReady" />
<LoginStory name="PasskeyReady" />
<LoginStory name="IdentikeyPending" args={{ identikey: 'pending' }} />
<LoginStory name="PasskeyPending" args={{ passkey: 'pending' }} />
<LoginStory name="Unconfigured" args={{ identikey: 'unconfigured' }} />
<LoginStory name="Canceled" args={{ passkey: 'canceled' }} />
<LoginStory name="Error" args={{ identikey: 'error', passkey: 'error' }} />

<PasskeySettingsStory name="Empty" args={{ credentials: [] }} />
<PasskeySettingsStory name="Supported" args={{ credentials: [passkey] }} />
<PasskeySettingsStory name="InsecureContext" args={{ availability: 'insecure', credentials: [] }} />
<PasskeySettingsStory name="Unsupported" args={{ availability: 'unsupported', credentials: [] }} />
<PasskeyRowStory name="Default" />
<PasskeyRowStory name="RenameInvalid" />
<PasskeyRowStory name="Remove" />
<PasskeyRowStory name="LastWithRecovery" args={{ lastPasskey: true, hasRecovery: true }} />
<PasskeyRowStory name="LastWithoutRecovery" args={{ lastPasskey: true, hasRecovery: false }} />
<PasskeyRowStory
	name="SaveFailed"
	args={{ error: 'We could not save that change. Your passkey remains available.' }}
/>

<PreferredAppsStory
	name="Configured"
	args={{
		preferences: [
			{
				capabilityId: 'manage-tasks',
				capabilityLabel: 'Manage tasks',
				applicationName: 'Vikunja',
				state: 'configured'
			}
		]
	}}
/>
<PreferredAppsStory
	name="Default"
	args={{
		preferences: [
			{
				capabilityId: 'work-with-pdfs',
				capabilityLabel: 'Work with PDFs',
				applicationName: 'Stirling PDF',
				state: 'default'
			}
		]
	}}
/>
<PreferredAppsStory
	name="ResetFailed"
	args={{
		preferences: [
			{
				capabilityId: 'listen-to-music',
				capabilityLabel: 'Listen to music',
				applicationName: 'Navidrome',
				state: 'reset-failed'
			}
		]
	}}
/>
<CapabilityStory
	name="Unavailable"
	args={{
		id: 'work-with-pdfs',
		label: 'Work with PDFs',
		summary: 'Open and organize PDF tools.',
		provider: 'Stirling PDF',
		state: 'unavailable'
	}}
/>
<CapabilityStory
	name="Unknown"
	args={{
		id: 'watch-video',
		label: 'Watch video',
		summary: 'Choose an app for your library.',
		provider: null,
		state: 'unknown'
	}}
/>

<FiltersStory name="Populated" />
<FiltersStory
	name="Filtered"
	args={{
		initial: { query: 'pdf', category: 'documents', availability: 'available' },
		resultCount: 1
	}}
/>
<FiltersStory
	name="NoResults"
	args={{ initial: { query: 'sewing', category: '', availability: '' }, resultCount: 0 }}
/>

<ChooserStory name="Multiple" args={{ viewer: 'member' }} />
<ChooserStory name="Guest" args={{ viewer: 'guest' }} />
<ChooserStory name="Saving" args={{ viewer: 'member', pending: true }} />
<ChooserStory
	name="SaveFailed"
	args={{
		viewer: 'member',
		error: 'We could not save that preference. Your selection is still here.'
	}}
/>
<ChooserStory name="NoEligibleProvider" args={{ providers: [] }} />

<DetailStory
	name="Available"
	args={{
		launchUrl: 'https://forgejo.example.test',
		sshAddress: 'ssh://edgebox.local:2222',
		capabilities: [{ id: 'host-code', label: 'Host code' }]
	}}
/>
<DetailStory
	name="SetupNeeded"
	args={{
		launchUrl: 'http://vaultwarden.example.test',
		name: 'Vaultwarden',
		summary: 'A password manager.',
		state: 'online',
		setupNotice: 'Set up trusted HTTPS before storing real credentials.'
	}}
/>
<DetailStory name="Unconfigured" args={{ launchUrl: null, capabilities: [] }} />
<DetailStory
	name="MultipleCapabilities"
	args={{
		capabilities: [
			{ id: 'host-code', label: 'Host code' },
			{ id: 'manage-tasks', label: 'Manage tasks' }
		]
	}}
/>
<DetailStory name="NoCapabilities" args={{ capabilities: [] }} />

<SystemStory
	name="Healthy"
	args={{
		services: [
			{ id: 'caddy', name: 'Caddy', detail: 'Routes local applications.', state: 'online' }
		],
		refreshedAt: 'a moment ago'
	}}
/>
<SystemStory name="Mixed" />
<SystemStory name="Refreshing" args={{ refreshing: true }} />
<SystemStory
	name="RefreshFailed"
	args={{ refreshError: 'Refresh could not finish. Previous observations are still shown.' }}
/>
<SystemStory name="RateLimited" args={{ retryAfter: 'in 30 seconds' }} />

<EmptyStory
	name="EmptyCatalog"
	args={{
		title: 'Your action shelf is still empty',
		message: 'An operator can add a curated application when it is ready.',
		actionLabel: 'Browse Applications',
		actionHref: '/applications'
	}}
/>
