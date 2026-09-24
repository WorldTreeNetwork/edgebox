/** Plain serializable data shared by server adapters and UI consumers. */
export type HealthState = 'unknown' | 'online' | 'unavailable' | 'stale';

export type Viewer = 'guest' | 'member' | 'operator';

export type HealthSummary = {
	state: HealthState;
	checkedAt: string | null;
};

export type ApplicationSummary = {
	id: string;
	name: string;
	summary: string;
	categoryIds: string[];
	capabilityIds: string[];
	launchUrl: string | null;
	health: HealthSummary;
	setupNotice: string | null;
};

export type CapabilitySummary = {
	id: string;
	label: string;
	summary: string;
	categoryId: string;
	providers: ApplicationSummary[];
	preferredProviderId: string | null;
	defaultProviderId: string | null;
};

export type ProviderResolution =
	| {
			kind: 'preferred' | 'default' | 'sole';
			provider: ApplicationSummary;
			alternatives: ApplicationSummary[];
			recoveryRequired: boolean;
	  }
	| { kind: 'chooser'; providers: ApplicationSummary[] }
	| { kind: 'no-provider'; providers: ApplicationSummary[] };
