import { and, asc, eq, inArray } from 'drizzle-orm';
import type { BetterSQLite3Database } from 'drizzle-orm/better-sqlite3';
import type {
	ApplicationSummary,
	CapabilitySummary,
	HealthSummary,
	ProviderResolution,
	Viewer
} from '#lib/catalog/index.js';
import {
	catalogApplication,
	catalogApplicationCategory,
	catalogCapability,
	catalogCapabilityProvider,
	catalogCategory,
	catalogEndpoint,
	catalogPreferredProvider
} from '#lib/server/db/schema.js';
import * as schema from '#lib/server/db/schema.js';

type Database = BetterSQLite3Database<typeof schema>;

type ApplicationRow = typeof catalogApplication.$inferSelect;
type CapabilityRow = typeof catalogCapability.$inferSelect;

export type CatalogHealthLookup = (applicationId: string) => HealthSummary;

export type CatalogRepositoryOptions = {
	healthForApplication?: CatalogHealthLookup;
};

export type ApplicationFilters = {
	viewer: Viewer;
	query?: string;
	categoryId?: string;
	availability?: 'available' | 'unavailable';
};

export type CapabilityFilters = {
	viewer: Viewer;
	userId?: string;
	query?: string;
	categoryId?: string;
};

export type SavePreferenceInput = {
	/** Derived by the server from the authenticated session, never a form field. */
	userId: string;
	capabilityId: string;
	applicationId: string;
	/** Derived from server-side authorization, never a browser-provided role. */
	viewer: Exclude<Viewer, 'guest'>;
};

const unknownHealth = (): HealthSummary => ({ state: 'unknown', checkedAt: null });

const visibleApplicationWhere = (viewer: Viewer) => {
	const visibleTo: ('public' | 'member' | 'operator')[] =
		viewer === 'guest'
			? ['public']
			: viewer === 'member'
				? ['public', 'member']
				: ['public', 'member', 'operator'];
	return and(
		eq(catalogApplication.enabled, true),
		inArray(catalogApplication.visibility, visibleTo)
	);
};

const normaliseQuery = (query: string | undefined) => query?.trim().toLocaleLowerCase() ?? '';

function approvedLaunchUrl(address: string | null, enabled: boolean | null): string | null {
	if (!address || !enabled) return null;
	try {
		const url = new URL(address);
		return (url.protocol === 'http:' || url.protocol === 'https:') && !url.username && !url.password
			? url.toString()
			: null;
	} catch {
		return null;
	}
}

/**
 * The route layer must derive userId from the authenticated server session;
 * this repository deliberately accepts only that trusted owner ID, never one
 * supplied by a browser preference payload.
 */
export function createCatalogRepository(
	database: Database,
	options: CatalogRepositoryOptions = {}
) {
	const healthForApplication = options.healthForApplication ?? unknownHealth;

	async function visibleApplications(viewer: Viewer): Promise<ApplicationRow[]> {
		return database
			.select()
			.from(catalogApplication)
			.where(visibleApplicationWhere(viewer))
			.orderBy(asc(catalogApplication.name));
	}

	async function applicationSummaries(
		applications: ApplicationRow[],
		viewer: Viewer
	): Promise<Map<string, ApplicationSummary>> {
		if (applications.length === 0) return new Map();
		const applicationIds = applications.map((application) => application.id);
		const [categoryRows, providerRows] = await Promise.all([
			database
				.select()
				.from(catalogApplicationCategory)
				.where(inArray(catalogApplicationCategory.applicationId, applicationIds)),
			database
				.select({
					applicationId: catalogCapabilityProvider.applicationId,
					capabilityId: catalogCapabilityProvider.capabilityId,
					address: catalogEndpoint.address,
					endpointEnabled: catalogEndpoint.enabled
				})
				.from(catalogCapabilityProvider)
				.innerJoin(
					catalogApplication,
					eq(catalogCapabilityProvider.applicationId, catalogApplication.id)
				)
				.leftJoin(
					catalogEndpoint,
					eq(catalogCapabilityProvider.launchEndpointId, catalogEndpoint.id)
				)
				.where(
					and(
						inArray(catalogCapabilityProvider.applicationId, applicationIds),
						visibleApplicationWhere(viewer)
					)
				)
		]);

		const categoriesByApplication = new Map<string, string[]>();
		for (const row of categoryRows) {
			const categories = categoriesByApplication.get(row.applicationId) ?? [];
			categories.push(row.categoryId);
			categoriesByApplication.set(row.applicationId, categories);
		}
		const providersByApplication = new Map<
			string,
			{ capabilityId: string; launchUrl: string | null }[]
		>();
		for (const row of providerRows) {
			const providers = providersByApplication.get(row.applicationId) ?? [];
			providers.push({
				capabilityId: row.capabilityId,
				launchUrl: approvedLaunchUrl(row.address, row.endpointEnabled)
			});
			providersByApplication.set(row.applicationId, providers);
		}

		return new Map(
			applications.map((application) => {
				const providers = providersByApplication.get(application.id) ?? [];
				return [
					application.id,
					{
						id: application.id,
						name: application.name,
						summary: application.summary,
						categoryIds: categoriesByApplication.get(application.id) ?? [],
						capabilityIds: providers.map((provider) => provider.capabilityId),
						launchUrl: providers.find((provider) => provider.launchUrl)?.launchUrl ?? null,
						health: healthForApplication(application.id),
						setupNotice: application.setupNotice
					}
				];
			})
		);
	}

	async function providerRows(capabilityId: string, viewer: Viewer) {
		return database
			.select({
				associationId: catalogCapabilityProvider.id,
				application: catalogApplication,
				address: catalogEndpoint.address,
				endpointEnabled: catalogEndpoint.enabled
			})
			.from(catalogCapabilityProvider)
			.innerJoin(
				catalogApplication,
				eq(catalogCapabilityProvider.applicationId, catalogApplication.id)
			)
			.leftJoin(catalogEndpoint, eq(catalogCapabilityProvider.launchEndpointId, catalogEndpoint.id))
			.where(
				and(
					eq(catalogCapabilityProvider.capabilityId, capabilityId),
					visibleApplicationWhere(viewer)
				)
			)
			.orderBy(asc(catalogApplication.name));
	}

	async function capabilitySummary(
		capability: CapabilityRow,
		viewer: Viewer,
		userId?: string
	): Promise<CapabilitySummary> {
		const rows = await providerRows(capability.id, viewer);
		const applications = rows.map((row) => row.application);
		const summaries = await applicationSummaries(applications, viewer);
		const providers = rows
			.map((row) => {
				const summary = summaries.get(row.application.id);
				if (!summary) return null;
				return { ...summary, launchUrl: approvedLaunchUrl(row.address, row.endpointEnabled) };
			})
			.filter((provider): provider is ApplicationSummary => provider !== null);
		const preference = userId
			? await database
					.select()
					.from(catalogPreferredProvider)
					.where(
						and(
							eq(catalogPreferredProvider.userId, userId),
							eq(catalogPreferredProvider.capabilityId, capability.id)
						)
					)
					.get()
			: undefined;
		const preferredRow = preference
			? rows.find((row) => row.associationId === preference.providerAssociationId)
			: undefined;

		return {
			id: capability.id,
			label: capability.label,
			summary: capability.summary,
			categoryId: capability.categoryId,
			providers,
			preferredProviderId: preferredRow?.application.id ?? null,
			defaultProviderId: providers.some(
				(provider) => provider.id === capability.defaultApplicationId
			)
				? capability.defaultApplicationId
				: null
		};
	}

	return {
		async listApplications(filters: ApplicationFilters): Promise<ApplicationSummary[]> {
			const applications = await visibleApplications(filters.viewer);
			const summaries = await applicationSummaries(applications, filters.viewer);
			let result = applications.map((application) => summaries.get(application.id)!);
			if (filters.categoryId) {
				result = result.filter((application) =>
					application.categoryIds.includes(filters.categoryId!)
				);
			}
			if (filters.availability) {
				result = result.filter((application) =>
					filters.availability === 'available'
						? application.health.state === 'online'
						: application.health.state === 'unavailable'
				);
			}
			const query = normaliseQuery(filters.query);
			if (query) {
				result = result.filter((application) =>
					`${application.name} ${application.summary}`.toLocaleLowerCase().includes(query)
				);
			}
			return result;
		},

		async listCapabilities(filters: CapabilityFilters): Promise<CapabilitySummary[]> {
			const query = normaliseQuery(filters.query);
			const capabilities = await database
				.select()
				.from(catalogCapability)
				.where(
					filters.categoryId ? eq(catalogCapability.categoryId, filters.categoryId) : undefined
				)
				.orderBy(asc(catalogCapability.displayOrder));
			const result = await Promise.all(
				capabilities.map((capability) =>
					capabilitySummary(capability, filters.viewer, filters.userId)
				)
			);
			return query
				? result.filter((capability) =>
						`${capability.label} ${capability.summary} ${capability.providers
							.map((provider) => `${provider.name} ${provider.summary}`)
							.join(' ')}`
							.toLocaleLowerCase()
							.includes(query)
					)
				: result;
		},

		async getCapability(
			id: string,
			viewer: Viewer,
			userId?: string
		): Promise<CapabilitySummary | null> {
			const capability = await database
				.select()
				.from(catalogCapability)
				.where(eq(catalogCapability.id, id))
				.get();
			return capability ? capabilitySummary(capability, viewer, userId) : null;
		},

		async resolveProvider(
			capabilityId: string,
			viewer: Viewer,
			userId?: string
		): Promise<ProviderResolution | null> {
			const capability = await this.getCapability(capabilityId, viewer, userId);
			if (!capability) return null;
			const eligible = capability.providers.filter((provider) => provider.launchUrl !== null);
			const preferred = eligible.find((provider) => provider.id === capability.preferredProviderId);
			if (preferred) {
				return {
					kind: 'preferred',
					provider: preferred,
					alternatives: eligible.filter((provider) => provider.id !== preferred.id),
					recoveryRequired: preferred.health.state === 'unavailable'
				};
			}
			const defaultProvider = eligible.find(
				(provider) => provider.id === capability.defaultProviderId
			);
			if (defaultProvider) {
				return {
					kind: 'default',
					provider: defaultProvider,
					alternatives: eligible.filter((provider) => provider.id !== defaultProvider.id),
					recoveryRequired: defaultProvider.health.state === 'unavailable'
				};
			}
			if (eligible.length === 1) {
				return { kind: 'sole', provider: eligible[0], alternatives: [], recoveryRequired: false };
			}
			return eligible.length > 1
				? { kind: 'chooser', providers: eligible }
				: { kind: 'no-provider', providers: capability.providers };
		},

		async savePreference({
			userId,
			capabilityId,
			applicationId,
			viewer
		}: SavePreferenceInput): Promise<void> {
			const association = await database
				.select({
					id: catalogCapabilityProvider.id,
					address: catalogEndpoint.address,
					endpointEnabled: catalogEndpoint.enabled
				})
				.from(catalogCapabilityProvider)
				.innerJoin(
					catalogApplication,
					eq(catalogCapabilityProvider.applicationId, catalogApplication.id)
				)
				.innerJoin(
					catalogEndpoint,
					eq(catalogCapabilityProvider.launchEndpointId, catalogEndpoint.id)
				)
				.where(
					and(
						eq(catalogCapabilityProvider.capabilityId, capabilityId),
						eq(catalogCapabilityProvider.applicationId, applicationId),
						eq(catalogEndpoint.applicationId, catalogApplication.id),
						visibleApplicationWhere(viewer)
					)
				)
				.get();
			if (!association || !approvedLaunchUrl(association.address, association.endpointEnabled)) {
				throw new Error('Provider is not eligible for this capability.');
			}
			await database
				.insert(catalogPreferredProvider)
				.values({ userId, capabilityId, providerAssociationId: association.id })
				.onConflictDoUpdate({
					target: [catalogPreferredProvider.userId, catalogPreferredProvider.capabilityId],
					set: { providerAssociationId: association.id }
				});
		},

		async resetPreference(userId: string, capabilityId: string): Promise<void> {
			await database
				.delete(catalogPreferredProvider)
				.where(
					and(
						eq(catalogPreferredProvider.userId, userId),
						eq(catalogPreferredProvider.capabilityId, capabilityId)
					)
				);
		},

		async listCategories() {
			return database.select().from(catalogCategory).orderBy(asc(catalogCategory.displayOrder));
		}
	};
}
