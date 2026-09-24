import type {
	ApplicationSummary,
	CapabilitySummary,
	ProviderResolution,
	Viewer
} from '#lib/catalog/index.js';
import type { createCatalogRepository } from '#lib/server/catalog/repository.js';
import { readDirectoryQuery } from './query';

type CatalogRepository = ReturnType<typeof createCatalogRepository>;
type SessionLocals = Pick<App.Locals, 'user' | 'session'>;

export type CapabilityDirectoryItem = CapabilitySummary & {
	resolution: ProviderResolution;
};

export type DirectoryIdentity = {
	viewer: Viewer;
	userId?: string;
};

export function identityFromLocals(locals: SessionLocals): DirectoryIdentity {
	return locals.user && locals.session
		? { viewer: 'member', userId: locals.user.id }
		: { viewer: 'guest' };
}

export function createDirectoryAdapter(repository: CatalogRepository) {
	async function capabilityItems(
		capabilities: CapabilitySummary[],
		identity: DirectoryIdentity
	): Promise<CapabilityDirectoryItem[]> {
		const items = await Promise.all(
			capabilities.map(async (capability) => {
				const resolution = await repository.resolveProvider(
					capability.id,
					identity.viewer,
					identity.userId
				);
				return resolution ? { ...capability, resolution } : null;
			})
		);
		return items.filter((item): item is CapabilityDirectoryItem => item !== null);
	}

	return {
		async home(locals: SessionLocals) {
			const identity = identityFromLocals(locals);
			const capabilities = await repository.listCapabilities({
				viewer: identity.viewer,
				userId: identity.userId
			});
			return {
				viewer: identity.viewer,
				capabilities: (await capabilityItems(capabilities, identity)).slice(0, 6)
			};
		},

		async capabilities(url: URL, locals: SessionLocals) {
			const identity = identityFromLocals(locals);
			const categories = await repository.listCategories();
			const filters = readDirectoryQuery(
				url,
				new Set(categories.map((category) => category.id)),
				false
			);
			const capabilities = await repository.listCapabilities({
				viewer: identity.viewer,
				userId: identity.userId,
				query: filters.query,
				categoryId: filters.category || undefined
			});
			return {
				viewer: identity.viewer,
				categories,
				filters,
				capabilities: await capabilityItems(capabilities, identity)
			};
		},

		async applications(url: URL, locals: SessionLocals) {
			const identity = identityFromLocals(locals);
			const categories = await repository.listCategories();
			const filters = readDirectoryQuery(
				url,
				new Set(categories.map((category) => category.id)),
				true
			);
			return {
				viewer: identity.viewer,
				categories,
				filters,
				applications: await repository.listApplications({
					viewer: identity.viewer,
					query: filters.query,
					categoryId: filters.category || undefined,
					availability: filters.availability || undefined
				})
			};
		},

		async capability(id: string, locals: SessionLocals) {
			const identity = identityFromLocals(locals);
			const [capability, resolution] = await Promise.all([
				repository.getCapability(id, identity.viewer, identity.userId),
				repository.resolveProvider(id, identity.viewer, identity.userId)
			]);
			return capability && resolution ? { viewer: identity.viewer, capability, resolution } : null;
		},

		async application(id: string, locals: SessionLocals) {
			const identity = identityFromLocals(locals);
			const [applications, capabilities] = await Promise.all([
				repository.listApplications({ viewer: identity.viewer }),
				repository.listCapabilities({
					viewer: identity.viewer,
					userId: identity.userId
				})
			]);
			const application = applications.find((candidate) => candidate.id === id);
			if (!application) return null;
			return {
				viewer: identity.viewer,
				application,
				capabilities: capabilities
					.filter((capability) =>
						capability.providers.some((provider) => provider.id === application.id)
					)
					.map(({ id: capabilityId, label }) => ({ id: capabilityId, label }))
			};
		},

		async savePreference(locals: SessionLocals, capabilityId: string, applicationId: string) {
			const identity = identityFromLocals(locals);
			if (!identity.userId || identity.viewer === 'guest')
				return { kind: 'auth-required' } as const;
			await repository.savePreference({
				userId: identity.userId,
				viewer: identity.viewer,
				capabilityId,
				applicationId
			});
			return { kind: 'saved' } as const;
		},

		async resetPreference(locals: SessionLocals, capabilityId: string) {
			const identity = identityFromLocals(locals);
			if (!identity.userId || identity.viewer === 'guest')
				return { kind: 'auth-required' } as const;
			await repository.resetPreference(identity.userId, capabilityId);
			return { kind: 'reset' } as const;
		}
	};
}

export function resolvedApplication(resolution: ProviderResolution): ApplicationSummary | null {
	return 'provider' in resolution ? resolution.provider : null;
}
