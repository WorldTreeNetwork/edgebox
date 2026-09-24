import { db } from '#lib/server/db/index.js';
import { createCatalogRepository } from '#lib/server/catalog/repository.js';
import { createDirectoryAdapter } from './adapter';

export const directory = createDirectoryAdapter(createCatalogRepository(db));

export { createDirectoryAdapter, identityFromLocals, resolvedApplication } from './adapter';
export { localReturnPath, MAX_DIRECTORY_QUERY_LENGTH, readDirectoryQuery } from './query';
