import {
	index,
	integer,
	primaryKey,
	sqliteTable,
	text,
	uniqueIndex
} from 'drizzle-orm/sqlite-core';
import { user } from './auth.schema';

export const task = sqliteTable('task', {
	id: text('id')
		.primaryKey()
		.$defaultFn(() => crypto.randomUUID()),
	title: text('title').notNull(),
	priority: integer('priority').notNull().default(1)
});

export * from './auth.schema';

export const catalogApplication = sqliteTable(
	'catalog_application',
	{
		id: text('id').primaryKey(),
		name: text('name').notNull(),
		summary: text('summary').notNull(),
		kind: text('kind', { enum: ['application', 'infrastructure'] }).notNull(),
		visibility: text('visibility', { enum: ['public', 'member', 'operator'] }).notNull(),
		enabled: integer('enabled', { mode: 'boolean' }).notNull().default(true),
		setupNotice: text('setup_notice')
	},
	(table) => [index('catalog_application_visibility_idx').on(table.visibility)]
);

export const catalogCategory = sqliteTable('catalog_category', {
	id: text('id').primaryKey(),
	label: text('label').notNull(),
	displayOrder: integer('display_order').notNull()
});

export const catalogApplicationCategory = sqliteTable(
	'catalog_application_category',
	{
		applicationId: text('application_id')
			.notNull()
			.references(() => catalogApplication.id, { onDelete: 'cascade' }),
		categoryId: text('category_id')
			.notNull()
			.references(() => catalogCategory.id, { onDelete: 'cascade' })
	},
	(table) => [primaryKey({ columns: [table.applicationId, table.categoryId] })]
);

export const catalogCapability = sqliteTable(
	'catalog_capability',
	{
		id: text('id').primaryKey(),
		label: text('label').notNull(),
		summary: text('summary').notNull(),
		categoryId: text('category_id')
			.notNull()
			.references(() => catalogCategory.id, { onDelete: 'restrict' }),
		displayOrder: integer('display_order').notNull(),
		defaultApplicationId: text('default_application_id').references(() => catalogApplication.id, {
			onDelete: 'set null'
		})
	},
	(table) => [index('catalog_capability_category_idx').on(table.categoryId)]
);

export const catalogEndpoint = sqliteTable(
	'catalog_endpoint',
	{
		id: text('id').primaryKey(),
		applicationId: text('application_id')
			.notNull()
			.references(() => catalogApplication.id, { onDelete: 'cascade' }),
		purpose: text('purpose', { enum: ['launch', 'health', 'ssh'] }).notNull(),
		address: text('address').notNull(),
		enabled: integer('enabled', { mode: 'boolean' }).notNull().default(true)
	},
	(table) => [index('catalog_endpoint_application_idx').on(table.applicationId)]
);

export const catalogCapabilityProvider = sqliteTable(
	'catalog_capability_provider',
	{
		id: text('id').primaryKey(),
		capabilityId: text('capability_id')
			.notNull()
			.references(() => catalogCapability.id, { onDelete: 'cascade' }),
		applicationId: text('application_id')
			.notNull()
			.references(() => catalogApplication.id, { onDelete: 'cascade' }),
		launchEndpointId: text('launch_endpoint_id').references(() => catalogEndpoint.id, {
			onDelete: 'set null'
		})
	},
	(table) => [
		uniqueIndex('catalog_capability_provider_pair_unique').on(
			table.capabilityId,
			table.applicationId
		),
		index('catalog_capability_provider_application_idx').on(table.applicationId)
	]
);

export const catalogPreferredProvider = sqliteTable(
	'catalog_preferred_provider',
	{
		userId: text('user_id')
			.notNull()
			.references(() => user.id, { onDelete: 'cascade' }),
		capabilityId: text('capability_id')
			.notNull()
			.references(() => catalogCapability.id, { onDelete: 'cascade' }),
		providerAssociationId: text('provider_association_id')
			.notNull()
			.references(() => catalogCapabilityProvider.id, { onDelete: 'cascade' })
	},
	(table) => [
		primaryKey({ columns: [table.userId, table.capabilityId] }),
		index('catalog_preferred_provider_association_idx').on(table.providerAssociationId)
	]
);
