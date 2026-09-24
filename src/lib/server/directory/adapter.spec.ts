import { mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { afterEach, describe, expect, it } from 'vitest';
import Database from 'better-sqlite3';
import { eq } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/better-sqlite3';
import { migrate } from 'drizzle-orm/better-sqlite3/migrator';
import { createCatalogRepository } from '#lib/server/catalog/repository.js';
import * as schema from '#lib/server/db/schema.js';
import { createDirectoryAdapter, identityFromLocals } from './adapter';
import { localReturnPath, MAX_DIRECTORY_QUERY_LENGTH, readDirectoryQuery } from './query';

const temporaryDirectories: string[] = [];

afterEach(() => {
	for (const directory of temporaryDirectories.splice(0)) rmSync(directory, { recursive: true });
});

function migratedDatabase() {
	const directory = mkdtempSync(path.join(tmpdir(), 'edgebox-directory-'));
	temporaryDirectories.push(directory);
	const client = new Database(path.join(directory, 'directory.db'));
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

function memberLocals(id: string): App.Locals {
	return {
		user: { id },
		session: { id: `session-${id}`, userId: id }
	} as App.Locals;
}

describe('directory server adapter', () => {
	it('bounds and normalizes shareable query state and local return paths', () => {
		const longQuery = `  ${'a'.repeat(200)}  `;
		const url = new URL(
			`http://edgebox.test/applications?q=${longQuery}&category=secret&availability=maybe`
		);
		const filters = readDirectoryQuery(url, new Set(['documents']), true);

		expect(filters).toEqual({
			query: 'a'.repeat(MAX_DIRECTORY_QUERY_LENGTH),
			category: '',
			availability: ''
		});
		expect(localReturnPath('/capabilities/manage-tasks?q=now')).toBe(
			'/capabilities/manage-tasks?q=now'
		);
		expect(localReturnPath('//attacker.test/path', '/capabilities')).toBe('/capabilities');
		expect(localReturnPath('https://attacker.test/path', '/capabilities')).toBe('/capabilities');
	});

	it('keeps guest data visibility-safe and returns only repository-approved launches', async () => {
		const adapter = createDirectoryAdapter(createCatalogRepository(migratedDatabase()));
		const result = await adapter.applications(
			new URL('http://edgebox.test/applications?q=forge'),
			{}
		);

		expect(result.viewer).toBe('guest');
		expect(result.applications.map((application) => application.id)).toEqual(['forgejo']);
		expect(result.applications[0]?.launchUrl).toBe('http://192.168.0.90:3000/');
		expect(await adapter.application('radarr', {})).toBeNull();
	});

	it('derives preference ownership from locals and preserves repository eligibility checks', async () => {
		const database = migratedDatabase();
		await addUser(database, 'member-a');
		await addUser(database, 'member-b');
		const adapter = createDirectoryAdapter(createCatalogRepository(database));

		expect(identityFromLocals({})).toEqual({ viewer: 'guest' });
		expect(await adapter.savePreference({}, 'manage-tasks', 'vikunja')).toEqual({
			kind: 'auth-required'
		});
		await expect(
			adapter.savePreference(memberLocals('member-a'), 'manage-tasks', 'forgejo')
		).rejects.toThrow('Provider is not eligible for this capability.');
		expect(
			await adapter.savePreference(memberLocals('member-a'), 'manage-tasks', 'vikunja')
		).toEqual({ kind: 'saved' });

		const rows = await database.select().from(schema.catalogPreferredProvider);
		expect(rows).toEqual([
			expect.objectContaining({ userId: 'member-a', capabilityId: 'manage-tasks' })
		]);
		expect(
			await database
				.select()
				.from(schema.catalogPreferredProvider)
				.where(eq(schema.catalogPreferredProvider.userId, 'member-b'))
		).toEqual([]);

		await adapter.resetPreference(memberLocals('member-a'), 'manage-tasks');
		expect(await database.select().from(schema.catalogPreferredProvider)).toEqual([]);
	});
});
