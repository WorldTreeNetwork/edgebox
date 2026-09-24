import { migrate } from 'drizzle-orm/better-sqlite3/migrator';
import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import * as schema from './schema';
import { DATABASE_URL } from '$app/env/private';

const databaseUrl = DATABASE_URL || 'local.db';
const client = new Database(databaseUrl);

client.pragma('journal_mode = WAL');
client.pragma('foreign_keys = ON');

export const db = drizzle(client, { schema });

// Migrations are idempotent: Drizzle records every applied migration and only
// runs new ones. Keeping this next to database initialization guarantees that
// every server process has an up-to-date schema before it serves a request.
migrate(db, { migrationsFolder: 'drizzle' });
