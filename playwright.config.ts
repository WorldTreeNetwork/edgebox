import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { defineConfig } from '@playwright/test';
import Database from 'better-sqlite3';
import { drizzle } from 'drizzle-orm/better-sqlite3';
import { migrate } from 'drizzle-orm/better-sqlite3/migrator';
import * as schema from './src/lib/server/db/schema';

const databaseDirectory = mkdtempSync(path.join(tmpdir(), 'edgebox-playwright-'));
const databasePath = path.join(databaseDirectory, 'edgebox.db');
const sqlite = new Database(databasePath);
sqlite.pragma('foreign_keys = ON');
migrate(drizzle(sqlite, { schema }), { migrationsFolder: path.resolve('drizzle') });
sqlite.close();
process.env.EDGEBOX_E2E_DATABASE_DIRECTORY = databaseDirectory;

export default defineConfig({
	testDir: './e2e',
	outputDir: path.join(databaseDirectory, 'test-results'),
	fullyParallel: false,
	workers: 1,
	use: {
		baseURL: 'http://127.0.0.1:4173',
		trace: 'retain-on-failure'
	},
	webServer: {
		command: 'bun run dev -- --host 127.0.0.1 --port 4173',
		url: 'http://127.0.0.1:4173',
		reuseExistingServer: false,
		env: {
			...process.env,
			DATABASE_URL: databasePath,
			ORIGIN: 'http://127.0.0.1:4173',
			BETTER_AUTH_SECRET: 'edgebox-playwright-secret-is-isolated-and-long'
		}
	},
	globalTeardown: './e2e/global-teardown.ts'
});
