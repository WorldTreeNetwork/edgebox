import { mkdtempSync, rmSync } from 'node:fs';
import path from 'node:path';
import { tmpdir } from 'node:os';
import { afterEach, describe, expect, it } from 'vitest';
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';
import { migrate } from 'drizzle-orm/better-sqlite3/migrator';
import { eq } from 'drizzle-orm';
import { createCatalogRepository } from './repository';
import * as schema from '#lib/server/db/schema.js';

const temporaryDirectories: string[] = [];

afterEach(() => {
	for (const directory of temporaryDirectories.splice(0)) rmSync(directory, { recursive: true });
});

function migratedDatabase() {
	const directory = mkdtempSync(path.join(tmpdir(), 'edgebox-catalog-'));
	temporaryDirectories.push(directory);
	const client = new Database(path.join(directory, 'catalog.db'));
	client.pragma('foreign_keys = ON');
	const database = drizzle(client, { schema });
	migrate(database, { migrationsFolder: path.resolve('drizzle') });
	return database;
}

async function addUser(database: ReturnType<typeof migratedDatabase>, id: string) {
	await database.insert(schema.user).values({
		id,
		name: id,
		email: `${id}@example.test`,
		emailVerified: false,
		createdAt: new Date(),
		updatedAt: new Date()
	});
}

describe('catalog migrations and repository', () => {
	it('seeds a migration-safe inventory without replacing a member preference', async () => {
		const database = migratedDatabase();
		const repository = createCatalogRepository(database);
		await addUser(database, 'member-a');
		await repository.savePreference({
			userId: 'member-a',
			capabilityId: 'manage-tasks',
			applicationId: 'vikunja',
			viewer: 'member'
		});

		migrate(database, { migrationsFolder: path.resolve('drizzle') });

		const applications = await repository.listApplications({ viewer: 'guest' });
		expect(applications.map((application) => application.id)).toContain('forgejo');
		expect(applications.map((application) => application.id)).not.toContain('radarr');
		const preference = await database
			.select()
			.from(schema.catalogPreferredProvider)
			.where(eq(schema.catalogPreferredProvider.userId, 'member-a'))
			.get();
		expect(preference?.providerAssociationId).toBe('manage-tasks--vikunja');

		const signature = await repository.getCapability('add-a-signature', 'guest');
		expect(signature?.providers).toEqual([]);
	});

	it('filters catalog data by visibility, category, availability, and visible provider text', async () => {
		const database = migratedDatabase();
		const repository = createCatalogRepository(database, {
			healthForApplication: (id) =>
				id === 'vikunja'
					? { state: 'online', checkedAt: '2026-09-21T00:00:00.000Z' }
					: { state: 'unknown', checkedAt: null }
		});

		const guestApps = await repository.listApplications({
			viewer: 'guest',
			categoryId: 'documents'
		});
		expect(guestApps.map((application) => application.id)).toEqual(['stirling-pdf']);
		expect(
			(await repository.listApplications({ viewer: 'guest' })).map((app) => app.id)
		).not.toContain('radarr');
		expect(
			(await repository.listApplications({ viewer: 'operator' })).map((app) => app.id)
		).toContain('radarr');
		expect(
			(await repository.listApplications({ viewer: 'guest', availability: 'available' })).map(
				(app) => app.id
			)
		).toEqual(['vikunja']);
		expect(
			(await repository.listCapabilities({ viewer: 'guest', query: 'vault' })).map(
				(capability) => capability.id
			)
		).toEqual(['manage-passwords']);
	});

	it('resolves defaults, keeps an unavailable preference, and isolates member preferences', async () => {
		const database = migratedDatabase();
		const repository = createCatalogRepository(database, {
			healthForApplication: (id) =>
				id === 'vikunja'
					? { state: 'unavailable', checkedAt: '2026-09-21T00:00:00.000Z' }
					: { state: 'unknown', checkedAt: null }
		});
		await addUser(database, 'member-a');
		await addUser(database, 'member-b');

		const defaultResolution = await repository.resolveProvider('manage-tasks', 'member');
		expect(defaultResolution).toMatchObject({
			kind: 'default',
			provider: { id: 'vikunja' },
			recoveryRequired: true
		});

		await repository.savePreference({
			userId: 'member-a',
			capabilityId: 'manage-tasks',
			applicationId: 'vikunja',
			viewer: 'member'
		});
		const memberResolution = await repository.resolveProvider('manage-tasks', 'member', 'member-a');
		expect(memberResolution).toMatchObject({
			kind: 'preferred',
			provider: { id: 'vikunja' },
			recoveryRequired: true
		});
		const otherMember = await repository.getCapability('manage-tasks', 'member', 'member-b');
		expect(otherMember?.preferredProviderId).toBeNull();

		await repository.resetPreference('member-a', 'manage-tasks');
		expect(
			(await repository.getCapability('manage-tasks', 'member', 'member-a'))?.preferredProviderId
		).toBeNull();
	});

	it('rejects a preference for an application outside the capability association', async () => {
		const database = migratedDatabase();
		const repository = createCatalogRepository(database);
		await addUser(database, 'member-a');

		await expect(
			repository.savePreference({
				userId: 'member-a',
				capabilityId: 'manage-tasks',
				applicationId: 'forgejo',
				viewer: 'member'
			})
		).rejects.toThrow('Provider is not eligible for this capability.');
		expect(
			await database
				.select()
				.from(schema.catalogPreferredProvider)
				.where(eq(schema.catalogPreferredProvider.userId, 'member-a'))
		).toEqual([]);
	});

	it('rejects a disabled or unlaunchable provider before persisting a preference', async () => {
		const database = migratedDatabase();
		const repository = createCatalogRepository(database);
		await addUser(database, 'member-a');
		await database
			.update(schema.catalogEndpoint)
			.set({ enabled: false })
			.where(eq(schema.catalogEndpoint.id, 'vikunja-launch'));

		await expect(
			repository.savePreference({
				userId: 'member-a',
				capabilityId: 'manage-tasks',
				applicationId: 'vikunja',
				viewer: 'member'
			})
		).rejects.toThrow('Provider is not eligible for this capability.');
		expect(
			await database
				.select()
				.from(schema.catalogPreferredProvider)
				.where(eq(schema.catalogPreferredProvider.userId, 'member-a'))
		).toEqual([]);
	});
});
